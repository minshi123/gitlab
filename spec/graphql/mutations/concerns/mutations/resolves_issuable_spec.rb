# frozen_string_literal: true

require 'spec_helper'

describe Mutations::ResolvesIssuable do
  let(:mutation_class) do
    Class.new(Mutations::BaseMutation) do
      include Mutations::ResolvesIssuable
    end
  end

  let(:project)  { create(:project) }
  let(:user)     { create(:user) }
  let(:context)  { { current_user: user } }
  let(:parent)   { issuable.project }
  let(:mutation) { mutation_class.new(object: nil, context: context, field: nil) }

  context 'with issues' do
    let(:issuable) { create(:issue, project: project) }

    it_behaves_like 'resolving an issuable in GraphQL', :issue
  end

  context 'with merge requests' do
    let(:issuable) { create(:merge_request, source_project: project) }

    it_behaves_like 'resolving an issuable in GraphQL', :merge_request
  end
end
