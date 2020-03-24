# frozen_string_literal: true

module OptionallySearch
  extend ActiveSupport::Concern

  class_methods do
    def search(*)
      raise(
        NotImplementedError,
        'Your model must implement the "search" class method'
      )
    end

    # Optionally limits a result set to those matching the given search query.
    def optionally_search(query = nil, **options)
      return all unless query.present?

      options.empty? ? search(query) : search(query, **options)
    end
  end
end
