# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20200312053852_populate_canonical_emails.rb')

describe PopulateCanonicalEmails do
  let(:users_table) { table(:users) }

  subject(:migration) { described_class.new }

  # rubocop: disable RSpec/FactoriesInMigrationSpecs
  let_it_be(:gmail_user1) { create(:user, email: "gmail.user@gmail.com") }
  let_it_be(:gmail_user2) { create(:user, email: "nice.gmail.user+withstuff@gmail.com") }
  let_it_be(:non_gmail_user1) { create(:user, email: "non.gmail.domain.user@gitlab.com") }
  let_it_be(:non_gmail_user2) { create(:user, email: "gitlab.user@gitlab.com") }
  # rubocop: enable RSpec/FactoriesInMigrationSpecs

  describe '#up' do
    it "only selects gmail users" do
      expect_next_instance_of(Gitlab::BackgroundMigration::PopulateCanonicalEmails) do |instance|
        expect(instance).to receive(:perform).with([
          having_attributes(id: gmail_user1.id),
          having_attributes(id: gmail_user2.id)
        ])
      end

      migrate!
    end
  end

  describe "#down" do
    before do
      migration.up
    end

    specify do
      expect { migration.down }.not_to change { UserCanonicalEmail.count }
    end
  end
end
