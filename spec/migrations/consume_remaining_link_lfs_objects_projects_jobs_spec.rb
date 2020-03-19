# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200319071702_consume_remaining_link_lfs_objects_projects_jobs.rb')

describe ConsumeRemainingLinkLfsObjectsProjectsJobs, :migration, :sidekiq do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:fork_networks) { table(:fork_networks) }
  let(:fork_network_members) { table(:fork_network_members) }
  let(:lfs_objects) { table(:lfs_objects) }
  let(:lfs_objects_projects) { table(:lfs_objects_projects) }

  let(:namespace) { namespaces.create(name: 'GitLab', path: 'gitlab') }

  let(:fork_network) { fork_networks.create(root_project_id: source_project.id) }

  let(:source_project) { projects.create(namespace_id: namespace.id) }
  let(:project) { projects.create(namespace_id: namespace.id) }
  let(:another_project) { projects.create(namespace_id: namespace.id) }

  let(:lfs_object) { lfs_objects.create(oid: 'abc123', size: 100) }
  let(:another_lfs_object) { lfs_objects.create(oid: 'def456', size: 200) }

  let!(:source_project_lop_1) do
    lfs_objects_projects.create(
      lfs_object_id: lfs_object.id,
      project_id: source_project.id
    )
  end

  let!(:source_project_lop_2) do
    lfs_objects_projects.create(
      lfs_object_id: another_lfs_object.id,
      project_id: source_project.id
    )
  end

  before do
    fork_network_members.create(fork_network_id: fork_network.id, project_id: source_project.id, forked_from_project_id: nil)

    [project, another_project].each do |p|
      fork_network_members.create(fork_network_id: fork_network.id, project_id: p.id, forked_from_project_id: source_project.id)

      lfs_objects_projects.create(lfs_object_id: lfs_object.id, project_id: p.id)
    end
  end

  it 'ensures all forks will have complete LFS objects linked to them' do
    expect(Gitlab::BackgroundMigration).to receive(:steal).with('LinkLfsObjectsProjects').and_call_original
    expect { migrate! }.to change { lfs_objects_projects.count }.by(2)
    expect(lfs_object_ids_for(project)).to match_array(lfs_object_ids_for(source_project))
    expect(lfs_object_ids_for(another_project)).to match_array(lfs_object_ids_for(source_project))
  end

  def lfs_object_ids_for(project)
    lfs_objects_projects.where(project_id: project.id).pluck(:lfs_object_id)
  end
end
