# frozen_string_literal: true

module Auditable
  def audit_required?
    ::Gitlab::Audit::EventQueue.active?
  end

  def audit_event_queue
    ::Gitlab::Audit::EventQueue.current
  end
end
