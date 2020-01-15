# frozen_string_literal: true

module MergeRequests
  class LinkLfsObjectsService < ::BaseService
    def execute(merge_request)
      return if merge_request.source_project == project
      return if no_changes?(merge_request)

      Projects::LfsPointers::LfsLinkService
        .new(project)
        .execute(lfs_oids(merge_request))
    end

    private

    def no_changes?(merge_request)
      merge_request.diff_head_sha == merge_request.diff_base_sha
    end

    def lfs_oids(merge_request)
      Gitlab::Git::LfsChanges
        .new(merge_request.source_project.repository, merge_request.diff_head_sha)
        .new_pointers(not_in: [merge_request.diff_base_sha])
        .map(&:lfs_oid)
    end
  end
end
