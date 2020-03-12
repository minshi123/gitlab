# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::BackgroundMigration::PopulateCanonicalEmails, :migration, schema: 20200312053852 do
  let(:migration) { described_class.new }
  let(:users_table) { table(:users) }
  let(:user_normalized_emails_table) { table(:user_normalized_emails) }

  let_it_be(:agent) { "user" }
  let_it_be(:agent_with_plus) { "userwithplus+somestuff" }
  let_it_be(:agent_with_periods) { "user.with.periods" }
  let_it_be(:agent_with_periods_and_plus) { "user.with.periods.and.plus+someotherstuff" }

  after do
    User.delete_all
  end

  subject do
    migration.perform(users)
  end

  let(:users) { users_table.all }

  # rubocop: disable RSpec/FactoriesInMigrationSpecs
  describe 'canonical emails' do
    using RSpec::Parameterized::TableSyntax

    where(:original_email, :expected_result) do
      'legitimateuser@gmail.com'                            | 'legitimateuser@gmail.com'
      'userwithplus+somestuff@gmail.com'                    | 'userwithplus@gmail.com'
      'user.with.periods@gmail.com'                         | 'userwithperiods@gmail.com'
      'user.with.periods.and.plus+someotherstuff@gmail.com' | 'userwithperiodsandplus@gmail.com'
    end

    with_them do
      it 'generates the correct canonical email' do
        user = create(:user, email: original_email)

        subject

        expect(user.reload.user_canonical_email.canonical_email).to eq expected_result
      end
    end
  end
  # rubocop: enable RSpec/FactoriesInMigrationSpecs
end
