# frozen_string_literal: true

module Resolvers
  class SprintResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource
    include TimeFrameArguments

    argument :state, Types::SprintStateEnum,
             required: false,
             description: 'Filter sprints by state'

    type Types::SprintType, null: true

    def resolve(**args)
      validate_timeframe_params!(args)

      authorize!

      SprintsFinder.new(sprints_finder_params(args)).execute
    end

    private

    def sprints_finder_params(args)
      {
        state: args[:state] || 'all',
        start_date: args[:start_date],
        end_date: args[:end_date]
      }.merge(parent_id_parameter)
    end

    def parent
      @parent ||= object.respond_to?(:sync) ? object.sync : object
    end

    def parent_id_parameter
      if parent.is_a?(Group)
        { group_ids: parent.id }
      elsif parent.is_a?(Project)
        { project_ids: parent.id }
      end
    end

    # SprintsFinder does not check for current_user permissions,
    # so for now we need to keep it here.
    def authorize!
      Ability.allowed?(context[:current_user], :read_sprint, parent) || raise_resource_not_available_error!
    end
  end
end
