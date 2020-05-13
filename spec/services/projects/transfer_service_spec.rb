# frozen_string_literal: true

require 'spec_helper'

describe Projects::TransferService do
  include GitHelpers

  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, :legacy_storage, namespace: user.namespace) }

  subject(:execute_transfer) { described_class.new(project, user).execute(group) }

  context 'namespace -> namespace' do
    before do
      allow_next_instance_of(Gitlab::UploadsTransfer) do |service|
        allow(service).to receive(:move_project).and_return(true)
      end
      allow_next_instance_of(Gitlab::PagesTransfer) do |service|
        allow(service).to receive(:move_project).and_return(true)
      end

      group.add_owner(user)
    end

    it 'updates the namespace' do
      transfer_result = execute_transfer

      expect(transfer_result).to be_truthy
      expect(project.namespace).to eq(group)
    end
  end

  context 'when transfer succeeds' do
    before do
      group.add_owner(user)
    end

    it 'sends notifications' do
      expect_any_instance_of(NotificationService).to receive(:project_was_moved)

      execute_transfer
    end

    it 'invalidates the user\'s personal_project_count cache' do
      expect(user).to receive(:invalidate_personal_projects_count)

      execute_transfer
    end

    it 'executes system hooks' do
      expect_next_instance_of(described_class) do |service|
        expect(service).to receive(:execute_system_hooks)
      end

      execute_transfer
    end

    it 'moves the disk path', :aggregate_failures do
      old_path = project.repository.disk_path
      old_full_path = project.repository.full_path

      execute_transfer

      project.reload_repository!

      expect(project.repository.disk_path).not_to eq(old_path)
      expect(project.repository.full_path).not_to eq(old_full_path)
      expect(project.disk_path).not_to eq(old_path)
      expect(project.disk_path).to start_with(group.path)
    end

    it 'updates project full path in .git/config' do
      execute_transfer

      expect(rugged_config['gitlab.fullpath']).to eq "#{group.full_path}/#{project.path}"
    end

    it 'updates storage location' do
      execute_transfer

      expect(project.project_repository).to have_attributes(
        disk_path: "#{group.full_path}/#{project.path}",
        shard_name: project.repository_storage
      )
    end
  end

  context 'when transfer fails' do
    let!(:original_path) { project_path(project) }

    def attempt_project_transfer(&block)
      expect do
        execute_transfer
      end.to raise_error(ActiveRecord::ActiveRecordError)
    end

    before do
      group.add_owner(user)

      expect_any_instance_of(Labels::TransferService).to receive(:execute).and_raise(ActiveRecord::StatementInvalid, "PG ERROR")
    end

    def project_path(project)
      Gitlab::GitalyClient::StorageSettings.allow_disk_access do
        project.repository.path_to_repo
      end
    end

    def current_path
      project_path(project)
    end

    it 'rolls back repo location' do
      attempt_project_transfer

      expect(project.repository.raw.exists?).to be(true)
      expect(original_path).to eq current_path
    end

    it 'rolls back project full path in .git/config' do
      attempt_project_transfer

      expect(rugged_config['gitlab.fullpath']).to eq project.full_path
    end

    it "doesn't send move notifications" do
      expect_any_instance_of(NotificationService).not_to receive(:project_was_moved)

      attempt_project_transfer
    end

    it "doesn't run system hooks" do
      attempt_project_transfer do |service|
        expect(service).not_to receive(:execute_system_hooks)
      end
    end

    it 'does not update storage location' do
      create(:project_repository, project: project)

      attempt_project_transfer

      expect(project.project_repository).to have_attributes(
        disk_path: project.disk_path,
        shard_name: project.repository_storage
      )
    end
  end

  context 'namespace -> no namespace' do
    let(:group) { nil }

    it 'does not allow the project transfer' do
      transfer_result = execute_transfer

      expect(transfer_result).to eq false
      expect(project.namespace).to eq(user.namespace)
      expect(project.errors.messages[:new_namespace].first).to eq 'Please select a new namespace for your project.'
    end
  end

  context 'disallow transferring of project with tags' do
    let(:container_repository) { create(:container_repository) }

    before do
      stub_container_registry_config(enabled: true)
      stub_container_registry_tags(repository: :any, tags: ['tag'])
      project.container_repositories << container_repository
    end

    it 'does not allow the project transfer' do
      expect(execute_transfer).to eq false
    end
  end

  context 'namespace -> not allowed namespace' do
    it 'does not allow the project transfer' do
      transfer_result = execute_transfer

      expect(transfer_result).to eq false
      expect(project.namespace).to eq(user.namespace)
    end
  end

  context 'namespace which contains orphan repository with same projects path name' do
    let(:fake_repo_path) { File.join(TestEnv.repos_path, group.full_path, "#{project.path}.git") }

    before do
      group.add_owner(user)

      TestEnv.create_bare_repository(fake_repo_path)
    end

    after do
      FileUtils.rm_rf(fake_repo_path)
    end

    it 'does not allow the project transfer' do
      transfer_result = execute_transfer

      expect(transfer_result).to eq false
      expect(project.namespace).to eq(user.namespace)
      expect(project.errors[:new_namespace]).to include('Cannot move project')
    end
  end

  context 'target namespace containing the same project name' do
    before do
      group.add_owner(user)
      create(:project, name: project.name, group: group, path: 'other')
    end

    it 'does not allow the project transfer' do
      transfer_result = execute_transfer

      expect(transfer_result).to eq false
      expect(project.namespace).to eq(user.namespace)
      expect(project.errors[:new_namespace]).to include('Project with same name or path in target namespace already exists')
    end
  end

  context 'target namespace containing the same project path' do
    before do
      group.add_owner(user)
      create(:project, name: 'other-name', path: project.path, group: group)
    end

    it 'does not allow the project transfer' do
      transfer_result = execute_transfer

      expect(transfer_result).to eq false
      expect(project.namespace).to eq(user.namespace)
      expect(project.errors[:new_namespace]).to include('Project with same name or path in target namespace already exists')
    end
  end

  context 'target namespace allows developers to create projects' do
    let(:group) { create(:group, project_creation_level: ::Gitlab::Access::DEVELOPER_MAINTAINER_PROJECT_ACCESS) }

    context 'the user is a member of the target namespace with developer permissions' do
      before do
        group.add_developer(user)
      end

      it 'does not allow project transfer to the target namespace' do
        transfer_result = execute_transfer

        expect(transfer_result).to eq false
        expect(project.namespace).to eq(user.namespace)
        expect(project.errors[:new_namespace]).to include('Transfer failed, please contact an admin.')
      end
    end
  end

  context 'visibility level' do
    let(:group) { create(:group, :internal) }

    before do
      group.add_owner(user)
    end

    context 'when namespace visibility level < project visibility level' do
      let(:project) { create(:project, :public, :repository, namespace: user.namespace) }

      before do
        execute_transfer
      end

      it { expect(project.visibility_level).to eq(group.visibility_level) }
    end

    context 'when namespace visibility level > project visibility level' do
      let(:project) { create(:project, :private, :repository, namespace: user.namespace) }

      before do
        execute_transfer
      end

      it { expect(project.visibility_level).to eq(Gitlab::VisibilityLevel::PRIVATE) }
    end
  end

  context 'missing group labels applied to issues or merge requests' do
    it 'delegates transfer to Labels::TransferService' do
      group.add_owner(user)

      expect_next_instance_of(Labels::TransferService, user, project.group, project) do |labels_transfer_service|
        expect(labels_transfer_service).to receive(:execute).once.and_call_original
      end

      execute_transfer
    end
  end

  context 'missing group milestones applied to issues or merge requests' do
    it 'delegates transfer to Milestones::TransferService' do
      group.add_owner(user)

      expect_next_instance_of(Milestones::TransferService, user, project.group, project) do |milestones_transfer_service|
        expect(milestones_transfer_service).to receive(:execute).once.and_call_original
      end

      execute_transfer
    end
  end

  context 'when hashed storage in use' do
    let!(:project) { create(:project, :repository, namespace: user.namespace) }
    let!(:old_disk_path) { project.repository.disk_path }

    before do
      group.add_owner(user)
    end

    it 'does not move the disk path', :aggregate_failures do
      new_full_path = "#{group.full_path}/#{project.path}"

      execute_transfer

      project.reload_repository!

      expect(project.repository).to have_attributes(
        disk_path: old_disk_path,
        full_path: new_full_path
      )
      expect(project.disk_path).to eq(old_disk_path)
    end

    it 'does not move the disk path when the transfer fails', :aggregate_failures do
      old_full_path = project.full_path

      expect_next_instance_of(described_class) do |service|
        allow(service).to receive(:execute_system_hooks).and_raise('foo')
      end

      expect { execute_transfer }.to raise_error('foo')

      project.reload_repository!

      expect(project.repository).to have_attributes(
        disk_path: old_disk_path,
        full_path: old_full_path
      )
      expect(project.disk_path).to eq(old_disk_path)
    end
  end

  describe 'refreshing project authorizations' do
    let(:group) { create(:group) }
    let(:owner) { project.namespace.owner }
    let(:group_member) { create(:user) }

    before do
      group.add_user(owner, GroupMember::MAINTAINER)
      group.add_user(group_member, GroupMember::DEVELOPER)
    end

    it 'refreshes the permissions of the old and new namespace' do
      execute_transfer

      expect(group_member.authorized_projects).to include(project)
      expect(owner.authorized_projects).to include(project)
    end

    it 'only schedules a single job for every user' do
      expect_next_instance_of(UserProjectAccessChangedService, [owner.id, group_member.id]) do |service|
        expect(service).to receive(:execute).once.and_call_original
      end

      execute_transfer
    end
  end

  def rugged_config
    rugged_repo(project.repository).config
  end
end
