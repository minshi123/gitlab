# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BackgroundMigration::PopulateCanonicalEmails, :migration, schema: 20200214030129 do
  let(:migration) { described_class.new }
  let(:users_table) { table(:users) }
  let(:user_normalized_emails_table) { table(:user_normalized_emails) }

  let_it_be(:agent) { "user" }
  let_it_be(:agent_with_plus) { "userwithplus+somestuff" }
  let_it_be(:agent_with_periods) { "user.with.periods" }
  let_it_be(:agent_with_periods_and_plus) { "user.with.periods.and.plus+someotherstuff" }

  let(:users) { users_table.all }

  # rubocop: disable RSpec/FactoriesInMigrationSpecs
  context 'generating canonical email address records for users with a primary gmail address' do
    let_it_be(:gmail_user) { create(:user, email: "#{agent}@gmail.com") }
    let_it_be(:gmail_user_with_plus_agent) { create(:user, email: "#{agent_with_plus}@gmail.com") }
    let_it_be(:gmail_user_with_period_agent) { create(:user, email: "#{agent_with_periods}@gmail.com") }
    let_it_be(:gmail_user_with_period_plus_agent) { create(:user, email: "#{agent_with_periods_and_plus}@gmail.com") }

    subject do
      migration.perform(users)
    end

    it 'creates UserCanonicalEmail records only from gmail addresses' do
      expect { subject }.to change(UserCanonicalEmail, :count).by(4)
    end
  end

  describe 'canonical emails' do
    using RSpec::Parameterized::TableSyntax

    after do
      User.delete_all
    end

    context 'for gmail addresses' do
      where(:original_email, :expected_result) do
        'legitimateuser@gmail.com'                  | 'legitimateuser@gmail.com'
        'userwithplus+somestuff@gmail.com'          | 'userwithplus@gmail.com'
        'user.with.periods@gmail.com'               | 'userwithperiods@gmail.com'
        'user.with.periods.and.plus+someotherstuff' | 'userwithperiodsandplus@gmail.com'
      end

      with_them do
        it 'generates the correct canonical email if needed' do
          ap "original email #{original_email}"
          user = build(:user, email: original_email)
          user.save(validate: false)

          subject

          user.reload

          ap user.email
          ap user.user_canonical_emails

          expect(user.user_canonical_emails.map(&:canonical_email).join('')).to eq expected_result
        end
      end
    end

    context 'for gmail addresses' do
      emails = [
        'user@gitlab.com',
        'user.with.periods@gitlab.com',
        'user.with.periods.plus@gitlab.com'
      ]

      emails.each do |original_email|
        it 'generates the correct canonical email if needed' do
          user = create(:user, email: original_email)

          subject

          expect(user.user_canonical_emails.count).to eq 0
        end
      end
    end
  end
  # rubocop: enable RSpec/FactoriesInMigrationSpecs
end
