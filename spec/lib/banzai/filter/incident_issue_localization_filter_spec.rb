# frozen_string_literal: true

require 'spec_helper'

describe Banzai::Filter::IncidentIssueLocalizationFilter do
  include FilterSpecHelper

  let_it_be(:project) { create(:project) }
  let_it_be(:incident) { create(:issue, :incident) }

  context 'with Start time in markdown' do
    subject { pipeline_result(body, context) }

    it 'localizes the date time' do
      pipeline_result
    end
  end
end
