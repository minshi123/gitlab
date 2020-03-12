# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    ##
    # The class to generate user canonical emails
    class PopulateCanonicalEmails
      def perform(range)
        return unless range.count > 0

        values = values_for_users(range)
        ap "values: #{values.inspect}"
        bulk_insert(values)
      end

      private

      def values_for_users(users)
        users.map do |user|
          {
              user_id: user.id,
              canonical_email: canonicalize_email(user.email),
              created_at: 'NOW()',
              updated_at: 'NOW()'
          }
        end
      end

      def bulk_insert(rows)
        Gitlab::Database.bulk_insert('user_canonical_emails',
                                     rows,
                                     disable_quote: [:created_at, :updated_at])
      end

      def canonicalize_email(email)
        portions = email.split('@')
        username = portions.shift
        rest = portions.join('')
        no_dots = username.tr('.', '')
        before_plus = no_dots.split('+')[0]
        "#{before_plus}@#{rest}"
      end
    end
  end
end
