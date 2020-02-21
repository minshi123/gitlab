# frozen_string_literal: true

require 'spec_helper'

describe MergeRequest::Metrics do
  describe 'associations' do
    it { is_expected.to belong_to(:merge_request) }
    it { is_expected.to belong_to(:latest_closed_by).class_name('User') }
    it { is_expected.to belong_to(:merged_by).class_name('User') }
  end

  describe '#review_time' do
    context 'without first comment calculated' do
      it 'is nil' do
        expect(subject.review_time).to be_nil
      end
    end

    context 'with first comment calculated' do
      before do
        subject.first_comment_at = 1.week.ago
      end

      context 'with non-merged MR' do
        it 'equals to Time.now - first_comment_at' do
          expect(subject.review_time).to be_like_time(Time.now - 1.week.ago)
        end
      end

      context 'with merged MR' do
        before do
          subject.merged_at = 1.day.ago
        end

        it 'equals to merged_at - first_comment_at' do
          expect(subject.review_time).to be_like_time(1.day.ago - 1.week.ago)
        end
      end
    end
  end
end
