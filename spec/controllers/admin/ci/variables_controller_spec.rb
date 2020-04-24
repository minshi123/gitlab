# frozen_string_literal: true

require 'spec_helper'

describe Admin::Ci::VariablesController do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe 'GET #show' do
    let!(:variable) { create(:ci_instance_variable) }

    subject do
      get :show, params: {}, format: :json
    end

    include_examples 'GET #show lists all variables'
  end

  describe 'PATCH #update' do
    let!(:variable) { create(:ci_instance_variable) }

    subject do
      patch :update,
        params: {
          variables_attributes: variables_attributes
        },
        format: :json
    end

    include_examples 'PATCH #update updates variables' do
      let(:variables_scope) { Ci::InstanceVariable.all }
      let(:file_variables_scope) { variables_scope.file }
    end
  end
end
