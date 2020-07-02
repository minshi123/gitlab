# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Auditable do
  let(:klazz) { Class.new { include Auditable } }

  subject(:instance) { klazz.new }

  describe '#audit_required?' do
    specify do
      allow(::Gitlab::Audit::EventQueue).to receive(:active?).and_return(true)

      expect(instance.audit_required?).to be_truthy
    end

    specify do
      allow(::Gitlab::Audit::EventQueue).to receive(:active?).and_return(false)

      expect(instance.audit_required?).to be_falsey
    end
  end

  describe '#audit_event_queue' do
    it 'gets the current event queue' do
      allow(::Gitlab::Audit::EventQueue).to receive(:current).and_return([])

      expect(instance.audit_event_queue).to eq([])
    end
  end
end
