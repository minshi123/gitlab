# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20200304160801_delete_template_services_duplicated_by_type.rb')

describe DeleteTemplateServicesDuplicatedByType do
  let(:services) { table(:services) }

  before do
    services.create!(template: true, type: 'JenkinsService')
    services.create!(template: true, type: 'JenkinsService')
    services.create!(template: true, type: 'JiraService')
    services.create!(template: true, type: 'JenkinsService')
  end

  it 'deletes service templates duplicated by type except the one with the lowest ID' do
    jenkins_service_id = services.find_by(type: 'JenkinsService').order(:id).pluck(:id)
    jira_service_id = services.find_by(type: 'JiraService').pluck(:id)

    migrate!

    expect(services.pluck(:id)).to contain_exactly(jenkins_service_id, jira_service_id)
  end
end
