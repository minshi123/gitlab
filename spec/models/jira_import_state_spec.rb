# frozen_string_literal: true

require 'rails_helper'

describe JiraImportState do
  describe "Associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:label).class_name('Issue') }
  end

  describe 'modules' do
    subject { described_class }

    it { is_expected.to include_module(AfterCommitQueue) }
  end
end
