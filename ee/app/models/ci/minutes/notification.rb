# frozen_string_literal: true

module Ci
  module Minutes
    class Notification
      include ::Gitlab::Utils::StrongMemoize

      attr_reader :message

      WARNING_LEVEL = 30
      DANGER_LEVEL = 5

      def initialize(context)
        @context = context
      end

      def show?
        if alert_reached?
          @message = s_("Pipelines|Group %{namespace_name} has exceeded its pipeline minutes quota. " \
          "Unless you buy additional pipeline minutes, no new jobs or pipelines in its projects will run.") %
            { namespace_name: context.namespace_name }
        elsif warning_reached?
          @message = s_("Pipelines|Group %{namespace_name} has %{notification_level}%% or less Shared Runner Pipeline" \
          " minutes remaining.  Once it runs out, no new jobs or pipelines in its projects will run.") %
            {
              namespace_name: context.namespace_name,
              notification_level: context.last_ci_minutes_usage_notification_level
            }
        end
      end

      def warning_reached?
        show_limit? && context.shared_runners_remaining_minutes_below_threshold?
      end

      def alert_reached?
        show_limit? && context.shared_runners_minutes_used?
      end

      private

      attr_reader :context

      def show_limit?
        strong_memoize(:show_limit) do
          context.shared_runners_minutes_limit_enabled? && context.can_see_status?
        end
      end
    end
  end
end
