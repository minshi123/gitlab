# frozen_string_literal: true

module Serverless
  class DomainCluster < ApplicationRecord
    self.table_name = 'serverless_domain_cluster'

    belongs_to :pages_domain
    belongs_to :knative, class_name: 'Clusters::Applications::Knative', foreign_key: 'clusters_applications_knative_id'
    belongs_to :creator, class_name: 'User', optional: true

    validates :pages_domain, :knative, :uuid, presence: true
    validates :uuid, uniqueness: true, length: { is: Gitlab::Serverless::Domain::UUID_LENGTH }

    before_validation :set_uuid, on: :create

    private

    def set_uuid
      self.uuid = generate_unique_uuid
    end

    def generate_unique_uuid
      3.times do
        uuid = Gitlab::Serverless::Domain.generate_uuid
        return uuid unless self.class.exists?(uuid)
      end
    end
  end
end
