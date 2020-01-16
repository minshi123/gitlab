# frozen_string_literal: true

require 'digest/sha1'

require 'pry'

module QA
  context 'Release', :docker do
    describe 'Git clone using a deploy key' do
      before do
        Flow::Login.sign_in

        @runner_name = "qa-runner-#{Time.now.to_i}"

        @project = Resource::Project.fabricate_via_api! do |resource|
          resource.name = 'deploy-key-clone-project'
        end

        @repository_location = @project.repository_ssh_location

        Resource::Runner.fabricate_via_api! do |resource|
          resource.project = @project
          resource.name = @runner_name
          resource.tags = %w[qa docker]
          resource.image = 'gitlab/gitlab-runner:ubuntu'
        end
      end

      after do
        Service::DockerRun::GitlabRunner.new(@runner_name).remove!
      end

      keys = [
        [Runtime::Key::RSA, 8192],
        [Runtime::Key::ECDSA, 521],
        [Runtime::Key::ED25519]
      ]

      keys.each do |(key_class, bits)|
        it "user sets up a deploy key with #{key_class}(#{bits}) to clone code using pipelines" do
          key = key_class.new(*bits)

          Resource::DeployKey.fabricate_via_browser_ui! do |resource|
            resource.project = @project
            resource.title = "deploy key #{key.name}(#{key.bits})"
            resource.key = key.public_key
          end

          deploy_key_name = "DEPLOY_KEY_#{key.name}_#{key.bits}"

          make_ci_variable(deploy_key_name, key)

          unless variable_created?
            Support::Retrier.retry_until(max_attempts: 2, sleep_interval: 1) do
              remove_variable(deploy_key_name)
              make_ci_variable(deploy_key_name, key)

              variable_created?
            end
          end

          gitlab_ci = <<~YAML
          cat-config:
            script:
              - mkdir -p ~/.ssh
              - ssh-keyscan -p #{@repository_location.port} #{@repository_location.host} >> ~/.ssh/known_hosts
              - eval $(ssh-agent -s)
              - ssh-add -D
              - echo "$#{deploy_key_name}" | ssh-add -
              - git clone #{@repository_location.git_uri}
              - cd #{@project.name}
              - git checkout #{deploy_key_name}
              - sha1sum .gitlab-ci.yml
            tags:
              - qa
              - docker
          YAML

          Resource::Repository::ProjectPush.fabricate! do |resource|
            resource.project = @project
            resource.file_name = '.gitlab-ci.yml'
            resource.commit_message = 'Add .gitlab-ci.yml'
            resource.file_content = gitlab_ci
            resource.branch_name = deploy_key_name
            resource.new_branch = true
          end

          sha1sum = Digest::SHA1.hexdigest(gitlab_ci)

          Page::Project::Menu.perform(&:click_ci_cd_pipelines)
          Page::Project::Pipeline::Index.perform(&:click_on_latest_pipeline)
          Page::Project::Pipeline::Show.perform(&:click_on_first_job)

          Page::Project::Job::Show.perform do |job|
            expect(job).to be_successful
            expect(job.output).to include(sha1sum)
          end
        end

        def make_ci_variable(key_name, key)
          Resource::CiVariable.fabricate_via_browser_ui! do |resource|
            resource.project = @project
            resource.key = key_name
            resource.value = key.private_key
            resource.masked = false
          end
          sleep 1
        end

        def variable_created?
          api_client = Runtime::API::Client.new(:gitlab)
          request = Runtime::API::Request.new(api_client, "/projects/#{@project.id}/variables")
          get request.url

          return if (json_body.empty? || json_body.first[:value].empty?)

          !(json_body.first[:value].empty?)
        end

        def remove_variable(key_name)
          Page::Project::Settings::CiVariables.perform(&:remove_variable)
        end
      end
    end
  end
end
