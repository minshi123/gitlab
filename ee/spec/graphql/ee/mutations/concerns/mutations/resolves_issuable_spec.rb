# frozen_string_literal: true

require 'spec_helper'

describe Mutations::ResolvesIssuable do
  let(:mutation_class) do
    Class.new(Mutations::BaseMutation) do
      include Mutations::ResolvesIssuable
    end
  end

  let(:group)    { create(:group) }
  let(:user)     { create(:user) }
  let(:context)  { { current_user: user } }
  let(:mutation) { mutation_class.new(object: nil, context: context, field: nil) }

  context 'with epics' do
    context 'when epic feature is enabled' do
      let(:issuable) { create(:epic, group: group) }
      let(:parent) { issuable.group }

      before do
        stub_licensed_features(epics: true)
      end

      it_behaves_like 'resolving an issuable in GraphQL', :epic
    end
  end
end
