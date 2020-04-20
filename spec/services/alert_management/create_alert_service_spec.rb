# frozen_string_literal: true

require 'spec_helper'

describe AlertManagement::CreateAlertService do
  let_it_be(:project) { create(:project, :repository, :private) }
  let(:service) { described_class.new(project, alert_payload) }
  let(:alert_payload) do
    {
      title: 'Alert title'
    }
  end

  subject { service.execute }

  describe '#execute' do
    it 'returns success' do
      is_expected.to eq(status: :success)
    end
  end
end
