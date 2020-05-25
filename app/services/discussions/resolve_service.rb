# frozen_string_literal: true

module Discussions
  class ResolveService < Discussions::BaseService
    include Gitlab::Utils::StrongMemoize

    def execute(one_or_more_discussions)
      @one_or_more_discussions = Array.wrap(one_or_more_discussions)

      ensure_discussions_are_for_same_noteable!

      @one_or_more_discussions.each do |discussion|
        resolve_discussion(discussion)
      end
    end

    private

    attr_accessor :one_or_more_discussions

    def ensure_discussions_are_for_same_noteable!
      return unless one_or_more_discussions.size > 1

      # Perform the checks without fetching extra records
      raise ArgumentError, 'Discussions must be all for the same noteable' \
        unless one_or_more_discussions.all? do |discussion|
          discussion.noteable_type == first_discussion.noteable_type &&
            discussion.noteable_id == first_discussion.noteable_id
        end
    end

    def resolve_discussion(discussion)
      return unless discussion.can_resolve?(current_user)

      discussion.resolve!(current_user)

      MergeRequests::ResolvedDiscussionNotificationService.new(project, current_user).execute(merge_request) if merge_request
      SystemNoteService.discussion_continued_in_issue(discussion, project, current_user, follow_up_issue) if follow_up_issue
    end

    def first_discussion
      @first_discussion ||= one_or_more_discussions.first
    end

    # Returns params[:merge_request] if present,
    # otherwise, returns the related merge request of the discussion.
    def merge_request
      strong_memoize(:merge_request) do
        next params[:merge_request] if params[:merge_request]

        first_discussion.noteable if first_discussion.for_merge_request?
      end
    end

    def follow_up_issue
      params[:follow_up_issue]
    end
  end
end
