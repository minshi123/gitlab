# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['Sprint'] do
  it { expect(described_class.graphql_name).to eq('Sprint') }

  it { expect(described_class).to require_graphql_authorizations(:read_sprint) }
end
