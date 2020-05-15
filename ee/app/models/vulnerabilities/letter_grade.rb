# frozen_string_literal: true

module Vulnerabilities
  class LetterGrade
    LETTER_GRADE_CONDITIONS = {
      a: 'critical = 0 and high = 0 and medium = 0 and low = 0',
      b: 'critical = 0 and high = 0 and medium = 0 and low > 0',
      c: 'critical = 0 and high = 0 and medium > 0',
      d: 'critical = 0 and high > 0',
      f: 'critical > 0'
    }.with_indifferent_access.freeze

    class << self
      def letter_grades_for(vulnerable)
        projects_filter_sql = vulnerable.projects.select(:id)
        from_clause = Vulnerabilities::Stats.where('project_id IN (?)', projects_filter_sql).to_sql
        sql_query = letter_grades_sql_for(from_clause)

        fetch_letter_grades(vulnerable, sql_query)
      end

      private

      def letter_grades_sql_for(from_clause)
        "SELECT #{count_clauses} FROM (#{from_clause}) as stats"
      end

      def count_clauses
        @count_clauses ||= LETTER_GRADE_CONDITIONS.map do |letter, condition|
          "count(*) filter (where #{condition}) as #{letter}"
        end.join(', ')
      end

      def fetch_letter_grades(vulnerable, sql_query)
        connection.execute(sql_query).first.map do |letter, count|
          new(vulnerable, letter, count)
        end
      end

      def connection
        ActiveRecord::Base.connection
      end
    end

    attr_reader :vulnerable, :letter, :count

    def initialize(vulnerable, letter, count)
      @vulnerable = vulnerable
      @letter = letter
      @count = count
    end

    def projects
      vulnerable.projects.where(id: projects_filter)
    end

    def ==(other)
      vulnerable == other.vulnerable &&
        letter == other.letter &&
        count == other.count
    end

    private

    def projects_filter
      Vulnerabilities::Stats.unscoped
                            .select(:project_id)
                            .from(Vulnerabilities::Stats.all)
                            .where(letter_grade_condition)
    end

    def letter_grade_condition
      LETTER_GRADE_CONDITIONS[letter]
    end
  end
end
