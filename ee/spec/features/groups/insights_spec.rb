# frozen_string_literal: true

require 'spec_helper'

describe 'Group Insights' do
  it_behaves_like 'Insights page' do
    let_it_be(:entity) { create(:group) }
    let(:route) { url_for([entity, :insights]) }
    let(:path) { group_insights_path(entity) }
  end
end
