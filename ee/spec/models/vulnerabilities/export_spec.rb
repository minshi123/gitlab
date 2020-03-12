# frozen_string_literal: true

require 'spec_helper'

describe Vulnerabilities::Export do
  it { is_expected.to define_enum_for(:format) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    subject(:export) { build(:vulnerability_export) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:format) }
    it { is_expected.not_to validate_presence_of(:file) }

    context 'when export is finished' do
      subject(:export) { build(:vulnerability_export, :finished) }

      it { is_expected.to validate_presence_of(:file) }
    end
  end

  describe '#status' do
    subject(:vulnerability_export) { create(:vulnerability_export, :csv) }

    around do |example|
      Timecop.freeze { example.run }
    end

    context 'when the export is new' do
      it { is_expected.to have_attributes(status: 'created') }
    end

    context 'when the export starts' do
      before do
        vulnerability_export.start!
      end

      it { is_expected.to have_attributes(status: 'running', started_at: Time.now) }
    end

    context 'when the export is running' do
      context 'and it finishes' do
        subject(:vulnerability_export) { create(:vulnerability_export, :csv, :with_file, :running) }

        before do
          vulnerability_export.finish!
        end

        it { is_expected.to have_attributes(status: 'finished', finished_at: Time.now) }
      end

      context 'and it fails' do
        subject(:vulnerability_export) { create(:vulnerability_export, :csv, :running) }

        before do
          vulnerability_export.failed!
        end

        it { is_expected.to have_attributes(status: 'failed', finished_at: Time.now) }
      end
    end
  end
end
