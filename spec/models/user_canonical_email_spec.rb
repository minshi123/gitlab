# frozen_string_literal: true

require 'spec_helper'

describe UserCanonicalEmail do
  it { is_expected.to belong_to(:user) }

  describe 'validations' do
    describe 'canonical_email' do
      it { is_expected.to validate_presence_of(:canonical_email) }
    end
  end
end
