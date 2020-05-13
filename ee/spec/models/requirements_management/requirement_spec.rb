# frozen_string_literal: true

require 'spec_helper'

describe RequirementsManagement::Requirement do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  describe 'associations' do
    subject { build(:requirement) }

    it { is_expected.to belong_to(:author).class_name('User') }
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    subject { build(:requirement) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_length_of(:title).is_at_most(::Issuable::TITLE_LENGTH_MAX) }
    it { is_expected.to validate_length_of(:title_html).is_at_most(::Issuable::TITLE_HTML_LENGTH_MAX) }
  end

  describe 'scopes' do
    describe '.counts_by_state' do
      let_it_be(:opened) { create(:requirement, project: project, state: :opened) }
      let_it_be(:archived) { create(:requirement, project: project, state: :archived) }

      subject { described_class.counts_by_state }

      it { is_expected.to contain_exactly(['archived', 1], ['opened', 1]) }
    end

    describe '.with_author' do
      let_it_be(:my_requirement) { create(:requirement, project: project, author: user) }
      let_it_be(:other_requirement) { create(:requirement, project: project) }

      subject { described_class.with_author(user) }

      it { is_expected.to contain_exactly(my_requirement) }
    end

    describe '.with_title_like' do
      let_it_be(:requirement_one) { create(:requirement, project: project, title: "it needs to do the thing") }
      let_it_be(:requirement_two) { create(:requirement, project: project, title: "it needs to not break") }

      subject { described_class.with_title_like(query) }

      context 'with a query that covers both' do
        let(:query) { 'it needs to' }

        it { is_expected.to contain_exactly(requirement_one, requirement_two) }
      end

      context 'with a query that covers neither' do
        let(:query) { 'break often' }

        it { is_expected.to be_empty }
      end

      context 'with a query that covers one' do
        let(:query) { 'do the thing' }

        it { is_expected.to contain_exactly(requirement_one) }
      end
    end
  end
end
