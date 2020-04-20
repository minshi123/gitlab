# frozen_string_literal: true

module AlertManagement
  class Alert < ApplicationRecord
    include AtomicInternalId
    include ShaAttribute

    belongs_to :project
    belongs_to :issue, optional: true
    has_internal_id :iid, scope: :project, init: ->(s) { s.project.alert_management_alerts.maximum(:iid) }

    self.table_name = 'alert_management_alerts'

    sha_attribute :fingerprint

    validates :title,           length: { maximum: 200 }, presence: true
    validates :description,     length: { maximum: 1000 }
    validates :service,         length: { maximum: 100 }
    validates :monitoring_tool, length: { maximum: 100 }
    validates :hosts,           length: { maximum: 255 }
    validates :project,         presence: true
    validates :events,          presence: true
    validates :severity,        presence: true
    validates :status,          presence: true
    validates :started_at,      presence: true

    enum severity: {
      critical: 0,
      high: 1,
      medium: 2,
      low: 3,
      info: 4,
      unknown: 5
    }

    enum status: {
      triggered: 0,
      acknowledged: 1,
      resolved: 2,
      ignored: 3
    }

    def fingerprint=(value)
      if value.blank?
        super(nil)
      else
        super(Digest::SHA1.hexdigest(value.to_s))
      end
    end
  end
end
