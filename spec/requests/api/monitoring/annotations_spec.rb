# frozen_string_literal: true

require 'spec_helper'

describe API::Monitoring::Annotations do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :private, :repository, namespace: user.namespace) }
  let_it_be(:environment) { create(:environment, project: project) }

  describe 'POST /environments/:environment_id/metrics_dashboard/annotations' do
    context 'with correct permissions' do
      it '' do
        expect(true).to eq(true)
      end
    end

    context 'without correct permissions' do
      it '' do
        expect(true).to eq(true)
      end
    end
  end
end
