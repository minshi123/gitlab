# frozen_string_literal: true

module Gitlab
  module StaticSiteEditor
    class Config
      include ActiveModel::Validations

      validates :commit, presence: true
      validate :only_master_branch
      validate :only_markdown
      validate :file_existence

      def initialize(repository, ref, file_path, return_url)
        @repository = repository
        @ref = ref
        @file_path = file_path
        @return_url = return_url
      end

      def payload
        {
          branch: ref,
          path: file_path,
          commit: commit&.id,
          project_id: project.id,
          project: project.path,
          namespace: project.namespace.path,
          return_url: return_url,
          is_supported_content: supported_content?
        }
      end

      private

      attr_reader :repository, :ref, :file_path, :return_url

      delegate :project, to: :repository

      def commit
        repository.commit(ref)
      end

      def supported_content?
        valid?
      end

      def only_master_branch
        return if ref == 'master'

        errors.add(:branch, 'Branch must be master')
      end

      def only_markdown
        return if File.extname(file_path) == '.md'

        errors.add(:extension, 'File must have a markdown extension')
      end

      def file_existence
        return if commit.blank?
        return if repository.blob_at(commit.id, file_path).present?

        errors.add(:file, 'File is not found')
      end
    end
  end
end
