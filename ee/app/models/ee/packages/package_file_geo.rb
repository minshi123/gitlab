# frozen_string_literal: true

module EE
  module Packages
    module PackageFileGeo
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        include ::Gitlab::Geo::ReplicableModel
        with_replicator Geo::PackageFileReplicator
      end
    end
  end
end
