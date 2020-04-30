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

    HOSTS_MAX_LENGTH = 255

    validates :title,           length: { maximum: 200 }, presence: true
    validates :description,     length: { maximum: 1_000 }
    validates :service,         length: { maximum: 100 }
    validates :monitoring_tool, length: { maximum: 100 }
    validates :project,         presence: true
    validates :events,          presence: true
    validates :severity,        presence: true
    validates :status,          presence: true
    validates :started_at,      presence: true
    validates :fingerprint,     uniqueness: { scope: :project }, allow_blank: true
    validate  :hosts_length

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

    scope :for_iid, -> (iid) { where(iid: iid) }

    # Sorting
    scope :order_start_time_asc, -> {  }
    scope :order_start_time_desc, -> {  }
    scope :order_end_time_asc, -> {  }
    scope :order_end_time_desc, -> {  }
    scope :order_events_count_asc, -> {  }
    scope :order_events_count_desc, -> {  }
    scope :order_severity_asc, -> {  }
    scope :order_severity_desc, -> {  }
    scope :order_status_asc, -> {  }
    scope :order_status_desc, -> {  }

    def self.sort_by_attribute(method)
      return all
      # TODO
      # case.to_s
      # when 'start_time_asc'     then order_start_time_asc
      # when 'start_time_desc'    then order_start_time_desc
      # when 'end_time_asc'       then order_end_time_asc
      # when 'end_time_desc'      then order_end_time_desc
      # when 'events_count_asc'   then order_events_count_asc
      # when 'events_count_desc'  then order_events_count_desc
      # when 'severity_asc'       then order_severity_asc
      # when 'severity_desc'      then order_severity_desc
      # when 'status_asc'         then order_status_asc
      # when 'status_desc'        then order_status_desc
      # else
      #   super
      # end
    end

    def fingerprint=(value)
      if value.blank?
        super(nil)
      else
        super(Digest::SHA1.hexdigest(value.to_s))
      end
    end

    private

    def hosts_length
      return unless hosts

      errors.add(:hosts, "hosts array is over #{HOSTS_MAX_LENGTH} chars") if hosts.join.length > HOSTS_MAX_LENGTH
    end
  end
end
