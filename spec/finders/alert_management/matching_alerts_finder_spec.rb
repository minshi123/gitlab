# frozen_string_literal: true

require 'spec_helper'
require 'ffaker'

describe AlertManagement::MatchingAlertsFinder, '#execute' do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let_it_be(:existing_attributes) do
    {
      monitoring_tool: 'Grafana',
      service: 'GitLab RSpec',
      title: 'Some error',
      description: 'Description',
      hosts: [FFaker::Internet.ip_v4_address],
      started_at: 1.minute.ago
    }
  end

  let_it_be(:alert) { create(:alert_management_alert, project: project, payload: existing_attributes, **existing_attributes) }

  describe '#execute' do
    subject { described_class.new(current_user, project, params).execute }

    before do
      project.add_developer(current_user)
    end

    context 'full payload matches' do
      let(:params) { alert.payload }

      it { is_expected.to match_array(alert) }
    end

    context 'detailed attribute matches' do
      let(:params) do
        existing_attributes.excluding(:hosts, :started_at)
      end

      it { is_expected.to match_array(alert) }
    end

    context 'detailed attribute matches' do
      let(:params) do
        existing_attributes.slice(:monitoring_tool, :service, :title, :description)
      end

      it { is_expected.to match_array(alert) }
    end

    context 'title and description matches' do
      let(:params) do
        existing_attributes.slice(:title, :description)
      end

      it { is_expected.to match_array(alert) }
    end

    context 'title only' do
      let(:params) do
        existing_attributes.slice(:title)
      end

      it { is_expected.to eq([]) }
    end
  end
end
