# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Runtime do
  before do
    allow(described_class).to receive(:process_name).and_return('ruby')
    stub_rails_env('production')
  end

  context "geo log cursor" do
    let(:geo_log_cursor_type) { double('::Rails::Console') }

    before do
      stub_const('::GeoLogCursorOptionParser', geo_log_cursor_type)
    end

    it "identifies itself" do
      expect(subject.identify).to eq(:geo_log_cursor)
      expect(subject.geo_log_cursor?).to be(true)
    end

    it "does not identify as others" do
      expect(subject.unicorn?).to be(false)
      expect(subject.sidekiq?).to be(false)
      expect(subject.rake?).to be(false)
      expect(subject.puma?).to be(false)
      expect(subject.console?).to be(false)
    end

    it "reports its maximum concurrency" do
      expect(subject.max_threads).to eq(1)
    end
  end
end
