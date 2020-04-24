# frozen_string_literal: true

module Ci
  module Minutes
    class Notification
      include ::Gitlab::Utils::StrongMemoize

      attr_reader :message

      PERCENTAGES = {
        warning: 30,
        danger: 5,
        exceeded: 0
      }.freeze

      def initialize(context)
        @context = context
      end

      def show?
        return unless show_limit?

        set_notifications

        true if notification_level
      end

      def warning_reached?
        show_limit? && context.shared_runners_remaining_minutes_below_threshold?
      end

      def alert_reached?
        show_limit? && context.shared_runners_minutes_used?
      end

      private

      attr_reader :context, :notification_level

      def show_limit?
        strong_memoize(:show_limit) do
          context.shared_runners_minutes_limit_enabled? && context.can_see_status?
        end
      end

      def set_notifications
        percentage = context.shared_runners_remaining_minutes_percent.to_i

        if percentage <= PERCENTAGES[:exceeded]
          @notification_level = :exceeded
          @message = exceeded_message
        elsif percentage <= PERCENTAGES[:danger]
          @notification_level = :danger
          @message = threshold_message
        elsif percentage <= PERCENTAGES[:warning]
          @notification_level = :warning
          @message = threshold_message
        end
      end

      def exceeded_message
        s_("Pipelines|Group %{namespace_name} has exceeded its pipeline minutes quota. " \
          "Unless you buy additional pipeline minutes, no new jobs or pipelines in its projects will run.") %
          { namespace_name: context.namespace_name }
      end

      def threshold_message
        s_("Pipelines|Group %{namespace_name} has %{percentage}%% or less Shared Runner Pipeline" \
          " minutes remaining.  Once it runs out, no new jobs or pipelines in its projects will run.") %
          {
            namespace_name: context.namespace_name,
            percentage: PERCENTAGES[notification_level]
          }
      end
    end
  end
end
