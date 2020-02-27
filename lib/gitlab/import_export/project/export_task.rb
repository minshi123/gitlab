# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Project
      class ExportTask
        include Gitlab::WithRequestStore

        def initialize(opts, logger: Logger.new($stdout))
          @project_path = opts.fetch(:project_path)
          @file_path = opts.fetch(:file_path)
          @current_user = User.find_by_username(opts.fetch(:username))
          namespace = Namespace.find_by_full_path(opts.fetch(:namespace_path))
          @project = namespace.projects.find_by_path(@project_path)
          @measurement_enabled = opts.fetch(:measurement_enabled)
          @measurable = Gitlab::Utils::Measuring.new(logger: logger) if @measurement_enabled
          @logger = logger
        end

        def export
          validate_project
          validate_file_path

          with_export do
            ::Projects::ImportExport::ExportService.new(project, current_user)
              .execute(Gitlab::ImportExport::AfterExportStrategies::MoveFileStrategy.new(archive_path: file_path))
          end

          logger.info 'Done!'
        end

        private

        attr_reader :measurable, :project, :current_user, :file_path, :project_path, :logger

        def validate_project
          raise "Project with path: #{project_path} was not found. Please provide correct project path" unless project
        end

        def validate_file_path
          directory = File.dirname(file_path)

          raise "Invalid file path: #{file_path}. Please provide correct file path" unless Dir.exist?(directory)
        end

        def with_export
          with_request_store do
            ::Gitlab::GitalyClient.allow_n_plus_1_calls do
              measurement_enabled? ? measurable.with_measuring { yield } : yield
            end
          end
        end

        def measurement_enabled?
          @measurement_enabled
        end
      end
    end
  end
end
