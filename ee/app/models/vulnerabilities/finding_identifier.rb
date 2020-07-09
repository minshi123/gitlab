# frozen_string_literal: true

module Vulnerabilities
  class FindingIdentifier < ApplicationRecord
    self.table_name = "vulnerability_occurrence_identifiers"

    belongs_to :finding, class_name: 'Vulnerabilities::Occurrence', inverse_of: :finding_identifiers
    belongs_to :identifier, class_name: 'Vulnerabilities::Identifier'

    validates :finding, presence: true
    validates :identifier, presence: true
    validates :identifier_id, uniqueness: { scope: [:occurrence_id] }
  end
end
