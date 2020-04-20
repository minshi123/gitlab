# frozen_string_literal: true

module Ci
  module Minutes
    class Threshold
      include ::Gitlab::Utils::StrongMemoize

      def initialize(user, context_level)
        @context_level = context_level
        @user = user
      end

      def warning_reached?
        show_limit? && context_level.shared_runners_remaining_minutes_below_threshold?
      end

      def alert_reached?
        show_limit? && context_level.shared_runners_minutes_used?
      end

      private

      attr_reader :user, :context_level

      def show_limit?
        strong_memoize(:show_limit) do
          context_level.shared_runners_minutes_limit_enabled? &&
            context_level.can_see_ci_minutes_warnings_for_user?(user)
        end
      end
    end
  end
end
