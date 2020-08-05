# frozen_string_literal: true

# Copy AwardEmoji from one awardable to another.
#
# This service expects the calling class to have performed the necessary
# authorization checks in order to allow the copy to happen.
module AwardEmojis
  class CopyService < ::BaseService
    def initialize(from_awardable, to_awardable)
      raise ArgumentError, 'Awardables must be different' if from_awardable == to_awardable

      super(from_awardable.project)

      @from_awardable = from_awardable
      @to_awardable = to_awardable
    end

    def execute
      award_emoji = from_awardable.award_emoji.map do |award|
        new_award = award.dup
        new_award.awardable = to_awardable
        new_award.save
        new_award
      end

      ServiceResponse.success(payload: { award_emoji: award_emoji })
    end

    private

    attr_accessor :from_awardable, :to_awardable
  end
end
