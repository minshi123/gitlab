# coding: utf-8
# frozen_string_literal: true

module Gitlab
  module SQL
    module Pattern
      extend ActiveSupport::Concern

      MIN_CHARS_FOR_PARTIAL_MATCHING = 3
      REGEX_QUOTED_WORD = /(?<=\A| )"[^"]+"(?= |\z)/.freeze

      class_methods do
        def fuzzy_search(query, columns, use_minimum_char_limit: true)
          matches = columns.map do |col|
            fuzzy_arel_match(col, query, use_minimum_char_limit: use_minimum_char_limit)
          end.compact.reduce(:or)

          coverages = columns.map do |col|
            fuzzy_arel_coverage(col, query)
          end

          # use the average approach, where the match has to be somewhat
          # present in all the searched columns to be ranked higher

          # a weighted average would be way better, because short fields
          # should have higher precedence than longer

          # we could use a non-linear function here to weight-in instead
          # (such as exp()) so that ~1 → 1 and <1 → 0 with a high ramp.
          avg_coverage = Arel::Nodes::Division.new(
            Arel::Nodes::Grouping.new(coverages.reduce(:+)),
            Arel::Nodes::NamedFunction.new("CAST", [Arel.sql(coverages.count.to_f.to_s).as("FLOAT"))
          )

          where(matches).order(avg_coverage.desc)
        end

        def to_pattern(query, use_minimum_char_limit: true)
          if partial_matching?(query, use_minimum_char_limit: use_minimum_char_limit)
            "%#{sanitize_sql_like(query)}%"
          else
            sanitize_sql_like(query)
          end
        end

        def min_chars_for_partial_matching
          MIN_CHARS_FOR_PARTIAL_MATCHING
        end

        def partial_matching?(query, use_minimum_char_limit: true)
          return true unless use_minimum_char_limit

          query.length >= min_chars_for_partial_matching
        end

        # column - The column name / Arel column to search in.
        # query - The text to search for.
        # lower_exact_match - When set to `true` we'll fall back to using
        #                     `LOWER(column) = query` instead of using `ILIKE`.
        def fuzzy_arel_match(column, query, lower_exact_match: false, use_minimum_char_limit: true)
          query = query.squish
          return unless query.present?

          arel_column = column.is_a?(Arel::Attributes::Attribute) ? column : arel_table[column]

          words = select_fuzzy_words(query, use_minimum_char_limit: use_minimum_char_limit)

          if words.any?
            words.map { |word| arel_column.matches(to_pattern(word, use_minimum_char_limit: use_minimum_char_limit)) }.reduce(:and)
          else
            # No words of at least 3 chars, but we can search for an exact
            # case insensitive match with the query as a whole
            if lower_exact_match
              Arel::Nodes::NamedFunction
                .new('LOWER', [arel_column])
                .eq(query)
            else
              arel_column.matches(sanitize_sql_like(query))
            end
          end
        end

        def fuzzy_arel_coverage(column, query)
          query = query.squish
          return unless query.present?

          arel_column = column.is_a?(Arel::Attributes::Attribute) ? column : arel_table[column]

          # coverage = query_len / column_len
          column_len = Arel::Nodes::NamedFunction.new("LENGTH", [arel_column])
          query_len = Arel::Nodes::NamedFunction.new("CAST",
                                                     [Arel.sql(query.length.to_s).as("FLOAT")])
          Arel::Nodes::Division.new(query_len, column_len)
        end

        def select_fuzzy_words(query, use_minimum_char_limit: true)
          quoted_words = query.scan(REGEX_QUOTED_WORD)

          query = quoted_words.reduce(query) { |q, quoted_word| q.sub(quoted_word, '') }

          words = query.split

          quoted_words.map! { |quoted_word| quoted_word[1..-2] }

          words.concat(quoted_words)

          words.select { |word| partial_matching?(word, use_minimum_char_limit: use_minimum_char_limit) }
        end
      end
    end
  end
end
