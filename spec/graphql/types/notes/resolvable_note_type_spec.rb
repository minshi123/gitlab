# frozen_string_literal: true
require 'spec_helper'

describe Types::Notes::ResolvableNoteType do
  specify do
    expect(described_class).to have_graphql_fields([:resolved, :resolvable, :resolved_by, :resolved_at])
  end
end
