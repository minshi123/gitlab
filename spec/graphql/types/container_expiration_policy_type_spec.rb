# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['ContainerExpirationPolicy'] do
  specify { expect(described_class.graphql_name).to eq('ContainerExpirationPolicy') }

  specify { expect(described_class.description).to eq('A tag expiration policy designed to keep only the images that matter most') }

  specify { expect(described_class).to require_graphql_authorizations(:destroy_container_image) }
end
