# frozen_string_literal: true
require 'spec_helper'

describe GitlabSchema.types['Discussion'] do
  specify do
    expected_fields = %i[
      id
      created_at
      notes
      reply_id
      resolved
      resolvable
      resolved_by
      resolved_at
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end

  specify { expect(described_class).to require_graphql_authorizations(:read_note) }
end
