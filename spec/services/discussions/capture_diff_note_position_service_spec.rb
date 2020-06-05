# frozen_string_literal: true

require 'spec_helper'

describe Discussions::CaptureDiffNotePositionService do
  subject { described_class.new(note.noteable, paths) }

  context 'image note on diff' do
    let!(:note) { create(:image_diff_note_on_merge_request) }
    let(:paths) { ['files/images/any_image.png'] }

    it 'is note affected by the service' do
      expect(Gitlab::Diff::PositionTracer).not_to receive(:new)

      expect(subject.execute(note.discussion)).to eq(nil)
      expect(note.diff_note_positions).to be_empty
    end
  end

  context 'when empty paths are passed as a param' do
    let!(:note) { create(:diff_note_on_merge_request) }
    let(:paths) { [] }

    it 'does not calculate positons' do
      expect(Gitlab::Diff::PositionTracer).not_to receive(:new)

      expect(subject.execute(note.discussion)).to eq(nil)
      expect(note.diff_note_positions).to be_empty
    end
  end

  context 'when position tracer returned nil position' do
    let!(:note) { create(:diff_note_on_merge_request) }
    let(:paths) { ['files/any_file.txt'] }

    it 'does not create diff note position' do
      expect(note.noteable).to receive(:merge_ref_head).and_return(double.as_null_object)
      expect_next_instance_of(Gitlab::Diff::PositionTracer) do |tracer|
        expect(tracer).to receive(:trace).and_return({ position: nil })
      end

      expect(subject.execute(note.discussion)).to eq(nil)
      expect(note.diff_note_positions).to be_empty
    end
  end
end
