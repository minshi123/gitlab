# frozen_string_literal: true

require 'spec_helper'

describe AlertManagement::Alert do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:issue) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:events) }
    it { is_expected.to validate_presence_of(:severity) }
    it { is_expected.to validate_presence_of(:status) }

    it { is_expected.to validate_length_of(:title).is_at_most(200) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000) }
    it { is_expected.to validate_length_of(:service).is_at_most(100) }
    it { is_expected.to validate_length_of(:monitoring_tool).is_at_most(100) }
    it { is_expected.to validate_length_of(:host).is_at_most(100) }
  end

  describe 'enums' do
    let(:severity_values) do
      { critical: 0, high: 1, medium: 2, low: 3, info: 4, unknown: 5 }
    end

    let(:status_values) do
      { triggered: 0, acknowledged: 1, resolved: 2, ignored: 3 }
    end

    it { is_expected.to define_enum_for(:severity).with_values(severity_values) }
    it { is_expected.to define_enum_for(:status).with_values(status_values) }
  end

  describe 'fingerprint setter' do
    let(:alert) { build(:alert_management_alert) }

    subject(:set_fingerprint) { alert.fingerprint = fingerprint }

    let(:fingerprint) { 'test' }

    it 'sets to the SHA1 of the value' do
      expect { set_fingerprint }
        .to change { alert.fingerprint }
        .from(nil)
        .to(Digest::SHA1.hexdigest(fingerprint))
    end

    describe 'testing length of 40' do
      where(:input) do
        [
          'test',
          'another test',
          'a' * 1000,
          12345
        ]
      end

      with_them do
        let(:fingerprint) { input }

        it 'sets the fingerprint to 40 chars' do
          set_fingerprint
          expect(alert.fingerprint.size).to eq(40)
        end
      end
    end

    context 'blank value given' do
      let(:fingerprint) { '' }

      it 'does not set the fingerprint' do
        expect { set_fingerprint }
          .not_to change { alert.fingerprint }
          .from(nil)
      end
    end
  end
end
