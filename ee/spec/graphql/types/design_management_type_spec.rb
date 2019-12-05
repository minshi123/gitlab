# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['DesignManagement'] do
  it do
    is_expected.to have_graphql_fields(:version, :design_at_version)
  end
end
