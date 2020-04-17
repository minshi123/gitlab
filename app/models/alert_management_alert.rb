class AlertManagementAlert < ApplicationRecord
  belongs_to :project
  belongs_to :issue, optional: true

  validates :title, presence: true, limit: 200
  validates_length_of :description, maximum: 1000
  validates_length_of :service, :monitoring_tool, :host, maximum: 100
  validates_length_of :fingerprint, maximum: 40
  validates_presence_of :events, :eseverity, :status

  enum severity: [:critical, :high, :medium, :low, :info, :unknown]
  enum status: [:triggered, :acknowledged, :resolved, :ignored]
end
