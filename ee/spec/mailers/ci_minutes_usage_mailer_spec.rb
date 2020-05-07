# frozen_string_literal: true

require 'spec_helper'

describe CiMinutesUsageMailer do
  include EmailSpec::Matchers

  describe '.notify' do
    let(:recipients) { %w(bob@example.com john@example.com) }

    subject { described_class.notify('GROUP_NAME', recipients) }

    it 'has the correct subject' do
      is_expected.to have_subject "Action required: There are no remaining Pipeline minutes for your group GROUP_NAME"
    end

    it 'has the correct subject' do
      is_expected.to bcc_to recipients
    end
  end
end
