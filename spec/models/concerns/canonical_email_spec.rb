# frozen_string_literal: true

require 'spec_helper'

describe CanonicalEmail do
  let(:fake_class) do
    Class.new do
      include CanonicalEmail

      attr_accessor :email
    end
  end
  let(:subject) { fake_class.new }

  before do
    stub_const("FakeClass", fake_class)
    stub_const("CanonicalEmail::INCLUDED_DOMAINS_PATTERN", [/includeddomain/])
  end

  describe "#canonicalize_email" do
    context 'when the email domain is included' do
      let(:expected_result) { 'user@includeddomain.com' }

      context 'the Agent has no periods nor a plus' do
        it 'returns the same email' do
          subject.email = 'user@includeddomain.com'

          expect(subject.canonicalize_email).to eq expected_result
        end
      end

      context 'the Agent has periods' do
        it 'removes the periods' do
          subject.email = 'u.s.e.r@includeddomain.com'

          expect(subject.canonicalize_email).to eq expected_result
        end
      end

      context 'the Agent has a plus' do
        it 'removes everything after the plus' do
          subject.email = 'user+123@includeddomain.com'

          expect(subject.canonicalize_email).to eq expected_result
        end
      end

      context 'the Agent has a plus and periods' do
        it 'removes the periods and everything after the plus' do
          subject.email = 'u.s.e.r+123@includeddomain.com'

          expect(subject.canonicalize_email).to eq expected_result
        end
      end
    end

    context 'when the email domain is not included' do
      it 'returns nil' do
        subject.email = "user@excludeddomain.com"

        expect(subject.canonicalize_email).to be_nil
      end
    end
  end
end
