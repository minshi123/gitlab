# frozen_string_literal: true

require 'spec_helper'

describe 'GET /-/security/vulnerable_projects' do
  it_behaves_like 'security dashboard JSON endpoint' do
    let(:security_dashboard_request) do
      get security_vulnerable_projects_path, headers: { 'ACCEPT' => 'application/json' }
    end
  end
end
