# frozen_string_literal: true

module Analytics
  class RefreshApprovalsData
    def initialize(*merge_requests)
      @merge_requests = merge_requests
    end

    def execute(force: false)
      merge_requests.each do |mr|
        metrics = mr.ensure_metrics

        next if !force && metrics.first_approved_at

        metrics.update!(first_approved_at: ProductivityCalculator.new(mr).first_approved_at)
      end
    end

    private

    attr_reader :merge_requests
  end
end
