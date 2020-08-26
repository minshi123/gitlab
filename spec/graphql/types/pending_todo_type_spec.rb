# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['PendingTodo'] do
  specify { expect(described_class.graphql_name).to eq('PendingTodo') }

  specify { expect(described_class).to have_graphql_fields(:pending_todo).only }
end
