# frozen_string_literal: true

module ContainerRegistry
  class EventsHandler
    def initialize(events)
      @events = events
    end

    def execute
      @events.each do |event|
        ::ContainerRegistry::EventHandler.new(event).execute
      end
    end
  end

  class EventHandler
    ALLOWED_ACTIONS = %w(push delete).freeze
    PUSH_ACTION = 'push'
    EVENT_TRACKING_CATEGORY = 'container_registry:notification'

    def initialize(event)
      @event = event
    end

    def execute
      return unless allowed_action?

      handle_event
      track_event
    end

    private

    def allowed_action?
      event_action.in?(ALLOWED_ACTIONS)
    end

    def track_event
      tracked_target = event_target_tag? ? :tag : :repository
      tracking_action = "#{event_action}_#{tracked_target}"

      if event_target_repository? && event_action_push? && !container_repository_exists?
        tracking_action = "create_repository"
      end

      ::Gitlab::Tracking.event(EVENT_TRACKING_CATEGORY, tracking_action)
    end

    def handle_event
      return unless event_target_media_type_manifest? || event_target_tag?
      return unless container_repository_exists?

      ::Geo::ContainerRepositoryUpdatedEventStore.new(find_container_repository!)
                                                 .create!
    end

    def container_repository_exists?
      ContainerRepository.exists_by_path?(container_registry_path)
    end

    def find_container_repository!
      ContainerRepository.find_by_path!(container_registry_path)
    end

    def container_registry_path
      ContainerRegistry::Path.new(@event['target']['repository'])
    end

    def event_target_media_type_manifest?
      @event['target']['mediaType'] =~ /manifest/
    end

    def event_target_tag?
      # There is no clear indication in the event structure when we delete a top-level manifest
      # except existance of "tag" key
      @event['target'].has_key?('tag')
    end

    def event_target_repository?
      @event['target'].has_key?('repository')
    end

    def event_action
      @event['action']
    end

    def event_action_push?
      PUSH_ACTION == event_action
    end
  end
end
