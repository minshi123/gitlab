# frozen_string_literal: true

require 'spec_helper'

describe ContainerRepository do
  let_it_be(:group) { create(:group, name: 'group') }
  let_it_be(:project) { create(:project, path: 'test', group: group) }
  let_it_be(:repository) { create(:container_repository, name: 'my_image', project: project) }

  describe '.exists_by_path?' do
    it 'returns true for known container repository paths' do
      path = ContainerRegistry::Path.new("#{project.full_path}/#{repository.name}")
      expect(described_class.exists_by_path?(path)).to be_truthy
    end

    it 'returns false for unknown container repository paths' do
      path = ContainerRegistry::Path.new('you/dont/know/me')
      expect(described_class.exists_by_path?(path)).to be_falsey
    end
  end
end
