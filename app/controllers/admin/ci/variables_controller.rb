# frozen_string_literal: true

class Admin::Ci::VariablesController < Admin::ApplicationController
  def show
    respond_to do |format|
      format.json { render_instance_variables }
    end
  end

  def update
    if update_variables
      respond_to do |format|
        format.json { render_instance_variables }
      end
    else
      respond_to do |format|
        format.json { render_error }
      end
    end
  end

  private

  def variables
    @variables ||= Ci::InstanceVariable.all
  end

  def render_instance_variables
    render status: :ok, json: { variables: Ci::InstanceVariableSerializer.new.represent(variables) }
  end

  def render_error
    render status: :bad_request, json: @records.map { |r| r.errors.full_messages }
  end

  def variables_params
    params.permit(variables_attributes: [*variable_params_attributes])
  end

  def variable_params_attributes
    %i[id variable_type key secret_value protected masked _destroy]
  end

  UNASSIGNABLE_KEYS = %w(id _destroy).freeze

  def update_variables
    vars = variables.index_by(&:id)
    Ci::InstanceVariable.transaction do
      @records = variables_params[:variables_attributes].map do |attributes|
        record = vars.fetch(attributes[:id].to_i) { Ci::InstanceVariable.new }
        record.assign_attributes(attributes.except(*UNASSIGNABLE_KEYS))
        record.mark_for_destruction if has_destroy_flag?(attributes)

        record
      end

      result = @records.map { |record| record.marked_for_destruction? ? record.destroy : record.save }.all?
      raise ActiveRecord::Rollback unless result

      result
    end
  end

  def has_destroy_flag?(hash)
    ActiveRecord::Type::Boolean.new.cast(hash["_destroy"])
  end
end
