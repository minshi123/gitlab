# frozen_string_literal: true

require 'spec_helper'

describe Serverless::DomainCluster do
  subject { create(:serverless_domain_cluster) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:pages_domain) }
    it { is_expected.to validate_presence_of(:knative) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_length_of(:uuid).is_equal_to(Gitlab::Serverless::Domain::UUID_LENGTH) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:pages_domain) }
    it { is_expected.to belong_to(:knative) }
    it { is_expected.to belong_to(:creator).optional }
  end

  describe '#set_uuid' do
    subject { build(:serverless_domain_cluster, uuid: nil) }

    context 'when a record with the generated uuid already exists' do
      before do
        subject.save!
      end

      it 'generates a different uuid' do
        domain = build(:serverless_domain_cluster)
        allow(Gitlab::Serverless::Domain).to receive(:generate_uuid).and_return(subject.uuid, subject.uuid, 'abcd1234567890')

        expect { domain.save! }.not_to raise_error
      end
    end

    context 'when record has not yet been persisted' do
      it 'assigns a uuid to the record before creation' do
        expect { subject.save! }.to change { subject.uuid }.from(nil).to(instance_of(String))
      end
    end

    context 'when record has already been persisted' do
      before do
        subject.save!
      end

      it 'does not change the uuid' do
        expect { subject.save! }.not_to change { subject.uuid }
      end
    end
  end
end
