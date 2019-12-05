# frozen_string_literal: true

module EE
  module Types
    module QueryType
      extend ActiveSupport::Concern

      prepended do
        field :design_management, ::Types::DesignManagementType,
              null: false,
              description: 'Fields related to design management'

        def design_management
          Object.new
        end
      end
    end
  end
end
