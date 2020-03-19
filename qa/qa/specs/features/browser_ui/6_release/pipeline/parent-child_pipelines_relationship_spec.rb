# frozen_string_literal: true

require 'securerandom'

module QA
  context 'Release', :docker do
    describe 'Parent-child pipelines relationship' do
      let!(:project_name) { "project-#{SecureRandom.hex(8)}" }
      let!(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = project_name
        end
      end
      let!(:runner) do
        Resource::Runner.fabricate_via_api! do |runner|
          runner.project = project
          runner.token = project.group.sandbox.runners_token
          runner.name = project_name
          runner.tags = ["#{project_name}"]
        end
      end

      before do
        Flow::Login.sign_in
      end

      after do
        runner.remove_via_api!
      end

      it 'parent pipelines succeeds if child succeeds' do
        push_success_child_pipeline_yml
        push_parent_pipeline_yml
        project.visit!

        view_pipelines

        Page::Project::Pipeline::Show.perform do |parent_pipeline|
          parent_pipeline.click_linked_job(project_name)

          expect(parent_pipeline).to have_job("child_job")
          expect(parent_pipeline).to be_passed
        end
      end

      it 'parent pipeline fails if child fails' do
        push_fail_child_pipeline_yml
        push_parent_pipeline_yml
        project.visit!

        view_pipelines

        Page::Project::Pipeline::Show.perform do |parent_pipeline|
          parent_pipeline.click_linked_job(project_name)

          expect(parent_pipeline).to have_job("child_job")
          expect(parent_pipeline).to be_failed
        end
      end

      private

      def view_pipelines
        Page::Project::Menu.perform(&:click_ci_cd_pipelines)
        Page::Project::Pipeline::Index.perform(&:wait_for_latest_pipeline_completion)
        Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)
      end

      def push_success_child_pipeline_yml
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = project
          project_push.file_name = '.child.yml'
          project_push.commit_message = 'Add .child.yml'
          project_push.file_content = <<~CI
            child_job:
              stage: test
              tags: ["#{project_name}"]
              script: echo "child job done!"

          CI
        end
      end

      def push_fail_child_pipeline_yml
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = project
          project_push.file_name = '.child.yml'
          project_push.commit_message = 'Add .child.yml'
          project_push.file_content = <<~CI
            child_job:
              stage: test
              tags: ["#{project_name}"]
              script: exit 1

          CI
        end
      end

      def push_parent_pipeline_yml
        Resource::Repository::ProjectPush.fabricate! do |project_push|
          project_push.project = project
          project_push.new_branch = false
          project_push.file_name = '.gitlab-ci.yml'
          project_push.commit_message = 'Add .gitlab-ci.yml'
          project_push.file_content = <<~CI
            stages:
              - test
              - deploy

            job1:
              stage: test
              trigger:
                include: ".child.yml"
                strategy: depend

            job2:
              stage: deploy
              tags: ["#{project_name}"]
              script: echo "parent deploy done"

          CI
        end
      end
    end
  end
end
