# frozen_string_literal: true

require 'spec_helper'

describe Issue do # rubocop: disable Gitlab/DuplicateSpecLocation
  subject { create(:issue) }

  describe 'associations' do
    it { is_expected.to have_many(:resource_weight_events) }
  end

  describe 'modules' do
    subject { described_class }

    it { is_expected.to include_module(EE::WeightEventable) }
  end
end
