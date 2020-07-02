# frozen_string_literal: true

module AuditEvents
  class BuildService
    def initialize(author:, scope:, target:, ip_address:, message:)
      @author = author
      @scope = scope
      @target = target
      @ip_address = ip_address
      @message = message
    end

    def execute
      SecurityEvent.new(payload)
    end

    private

    def payload
      if License.feature_available?(:admin_audit_log)
        {
          author_id: @author.id,
          author_name: @author.name,
          entity_id: @scope.id,
          entity_type: @scope.class.name,
          details: {
            author_name: @author.name,
            target_id: @target.id,
            target_type: @target.class.name,
            target_details: @target.name,
            custom_message: @message,
            ip_address: @ip_address,
            entity_path: @scope.full_path
          },
          ip_address: ip_address,
          created_at: DateTime.current
        }
      else
        {
          author_id: @author.id,
          author_name: @author.name,
          entity_id: @scope.id,
          entity_type: @scope.class.name,
          details: {
            author_name: @author.name,
            target_id: @target.id,
            target_type: @target.class.name,
            target_details: @target.name,
            custom_message: @message
          },
          created_at: DateTime.current
        }
      end
    end

    def ip_address
      @ip_address.presence || @author.current_sign_in_ip
    end
  end
end
