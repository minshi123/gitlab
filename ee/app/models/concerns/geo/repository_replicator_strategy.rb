# frozen_string_literal: true

# module Geo
#   module RepositoryReplicatorStrategy
#     extend ActiveSupport::Concern

#     include Delay
#     include Gitlab::Geo::LogHelpers

#     included do
#       event :created
#       event :updated
#       event :deleted
#     end

#     def deleted_params
#       { model_record_id: model_record.id }
#     end
#   end
# end
