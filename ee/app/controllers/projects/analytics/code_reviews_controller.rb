# frozen_string_literal: true

module Projects
  module Analytics
    class CodeReviewsController < Projects::ApplicationController
      before_action :authorize_read_code_review_analytics!
      before_action do
        push_frontend_feature_flag(:code_review_analytics_has_new_search)
        push_frontend_feature_flag(:not_issuable_queries, @project, default_enabled: true)
      end

      def index
      end
    end
  end
end
