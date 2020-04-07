# frozen_string_literal: true

module Gitlab
  module StaticSiteEditor
    class Config
      attr_reader :repository, :ref, :file_path, :return_url

      def initialize(repository, ref, file_path, return_url)
        @repository = repository
        @ref = ref
        @file_path = file_path
        @return_url = return_url
      end

      delegate :project, to: :repository

      def commit
        repository.commit(ref)
      end

      def payload
        {
          branch: ref,
          path: file_path,
          commit: commit.id,
          project_id: project.id,
          project: project.path,
          namespace: project.namespace.path,
          return_url: return_url
        }
      end
    end
  end
end
