module EE
  module IssuableFinder
    module Params
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override


      override :assignees
      # rubocop: disable CodeReuse/ActiveRecord
      def assignees
        strong_memoize(:assignees) do
          if assignee_ids?
            ::User.where(id: params[:assignee_ids])
          else
            super
          end
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
