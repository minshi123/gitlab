# frozen_string_literal: true
require 'spec_helper'

describe 'getting Alert Management Alerts' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:alert_1) { create(:alert_management_alert, project: project) }
  let_it_be(:alert_2) { create(:alert_management_alert, project: project) }

  let(:fields) do
    <<~QUERY
      nodes {
        #{all_graphql_fields_for('AlertManagementAlert'.classify)}
      }
    QUERY
  end

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('alertManagementAlerts', {}, fields)
    )
  end

  context 'with alert data' do
    let(:alerts) { graphql_data.dig('project', 'alertManagementAlerts', 'nodes') }

    context 'without project permissions' do
      let(:user) { create(:user) }

      before do
        post_graphql(query, current_user: current_user)
      end

      it_behaves_like 'a working graphql query'

      it { expect(alerts).to be nil }
    end

    context 'with project permissions' do
      before do
        project.add_developer(current_user)
        post_graphql(query, current_user: current_user)
      end

      let(:first_alert) { alerts.first }

      it_behaves_like 'a working graphql query'

      it { expect(alerts.size).to eq(2) }
      it { expect(first_alert['iid']).to eql alert_2.iid.to_s }
      it { expect(first_alert['title']).to eql alert_2.title }
      it { expect(first_alert['severity']).to eql alert_2.severity }
      it { expect(first_alert['status']).to eql alert_2.status }
      it { expect(first_alert['monitoring_tool']).to eql alert_2.monitoring_tool }
      it { expect(first_alert['service']).to eql alert_2.service }
      it { expect(first_alert['eventCount']).to eql alert_2.events }

      it do
        expect(
          first_alert['startedAt']
        ).to eql alert_2.started_at.strftime('%Y-%m-%dT%H:%M:%SZ')
      end

      it do
        expect(
          first_alert['endedAt']
        ).to eql alert_2.ended_at&.strftime('%Y-%m-%dT%H:%M:%SZ')
      end

      context 'with iid given' do
        let(:query) do
          graphql_query_for(
            'project',
            { 'fullPath' => project.full_path },
            query_graphql_field('alertManagementAlerts', { iid: alert_1.iid.to_s }, fields)
          )
        end

        it_behaves_like 'a working graphql query'

        it { expect(alerts.size).to eq(1) }
        it { expect(first_alert['iid']).to eql alert_1.iid.to_s }
      end
    end
  end
end
