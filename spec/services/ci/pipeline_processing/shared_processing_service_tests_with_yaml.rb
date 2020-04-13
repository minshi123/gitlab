# frozen_string_literal: true

shared_examples 'Pipeline Processing Service Tests With Yaml' do
  Dir.glob(Rails.root.join('spec/services/ci/pipeline_processing/test_cases/*.yml')) do |file_path|
    context "test for: #{file_path}", :sidekiq_inline do
      let(:user) { create(:user) }
      let(:project) { create(:project, :repository) }

      let(:test_file) { YAML.load_file(file_path) }

      before do
        stub_ci_pipeline_yaml_file(YAML.dump(test_file['config']))
        stub_not_protect_default_branch
        project.add_developer(user)
      end

      let!(:pipeline) { Ci::CreatePipelineService.new(project, user, ref: 'master').execute(:pipeline) }

      it 'follows transitions' do
        test_file['transitions'].each do |transition|
          case transition['event']
          when 'start'
            expect(pipeline).to be_persisted
            check_expectation(transition['expect'])
          when 'succeed'
            succeed_jobs(transition['jobs'])
            check_expectation(transition['expect'])
          when 'fail'
            fail_jobs(transition['jobs'])
            check_expectation(transition['expect'])
          end
        end
      end

      private

      def check_expectation(expectation)
        expectation.each do |key, value|
          case key
          when 'pipeline'
            expect(pipeline.reload.status).to eq(value)
          when 'stages'
            value.each do |name, status|
              expect(stage_by_name(name).status).to eq(status)
            end
          when 'builds'
            value.each do |name, status|
              expect(build_by_name(name).status).to eq(status)
            end
          end
        end
      end

      def succeed_jobs(job_names)
        job_names.each do |job_name|
          build_by_name(job_name).reset.success!
        end
      end

      def fail_jobs(job_names)
        job_names.each do |job_name|
          build_by_name(job_name).reset.drop!
        end
      end

      def stage_by_name(name)
        pipeline.stages.find_by!(name: name)
      end

      def build_by_name(name)
        pipeline.builds.find_by!(name: name)
      end
    end
  end
end
