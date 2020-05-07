# frozen_string_literal: true

module API
  class Admin::Ci::InstanceVariables < Grape::API
    include PaginationParams

    before { authenticated_as_admin! }

    namespace 'admin' do
      namespace 'ci' do
        desc 'Get instance level variables' do
          success Entities::Variable
        end
        params do
          use :pagination
        end
        get 'instance_variables' do
          variables = ::Ci::InstanceVariable.all

          present paginate(variables), with: Entities::Variable
        end

        desc 'Get a specific variable from a group' do
          success Entities::Variable
        end
        params do
          requires :key, type: String, desc: 'The key of the variable'
        end
        get 'instance_variables/:key' do
          key = params[:key]
          variable = ::Ci::InstanceVariable.find_by_key(key)

          break not_found!('InstanceVariable') unless variable

          present variable, with: Entities::Variable
        end

        desc 'Create a new variable in a group' do
          success Entities::Variable
        end
        params do
          requires :key,
            type: String,
            desc: 'The key of the variable'

          requires :value,
            type: String,
            desc: 'The value of the variable'

          optional :protected,
            type: String,
            desc: 'Whether the variable is protected'

          optional :masked,
            type: String,
            desc: 'Whether the variable is masked'

          optional :variable_type,
            type: String,
            values: ::Ci::InstanceVariable.variable_types.keys,
            desc: 'The type of variable, must be one of env_var or file. Defaults to env_var'
        end
        post 'instance_variables' do
          variable_params = declared_params(include_missing: false)

          variable = ::Ci::InstanceVariable.new(variable_params)

          if variable.save
            present variable, with: Entities::Variable
          else
            render_validation_error!(variable)
          end
        end

        desc 'Update an existing variable from a group' do
          success Entities::Variable
        end
        params do
          optional :key,
            type: String,
            desc: 'The key of the variable'

          optional :value,
            type: String,
            desc: 'The value of the variable'

          optional :protected,
            type: String,
            desc: 'Whether the variable is protected'

          optional :masked,
            type: String,
            desc: 'Whether the variable is masked'

          optional :variable_type,
            type: String,
            values: ::Ci::InstanceVariable.variable_types.keys,
            desc: 'The type of variable, must be one of env_var or file'
        end
        put 'instance_variables/:key' do
          variable = ::Ci::InstanceVariable.find_by_key(params[:key])

          break not_found!('InstanceVariable') unless variable

          variable_params = declared_params(include_missing: false).except(:key)

          if variable.update(variable_params)
            present variable, with: Entities::Variable
          else
            render_validation_error!(variable)
          end
        end

        desc 'Delete an existing variable from a group' do
          success Entities::Variable
        end
        params do
          requires :key, type: String, desc: 'The key of the variable'
        end
        delete 'instance_variables/:key' do
          variable = ::Ci::InstanceVariable.find_by_key(params[:key])
          not_found!('InstanceVariable') unless variable

          variable.destroy

          no_content!
        end
      end
    end
  end
end
