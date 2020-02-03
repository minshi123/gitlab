# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200203104214_serivces_remove_temporary_index_on_project_id.rb')

describe SerivcesRemoveTemporaryIndexOnProjectId, :migration do
  let(:migration) { described_class.new }

  describe '#up' do
    context 'index exists' do
      it 'removes temporary partial index' do
        migration.down

        expect { migration.up }.to change { migration.index_exists?(:services, :project_id, name: described_class::INDEX_NAME) }.from(true).to(false)
      end
    end

    context 'index does not exist' do
      it 'skips removal action' do
        expect { migration.up }.not_to change { migration.index_exists?(:services, :project_id, name: described_class::INDEX_NAME) }
      end
    end
  end

  describe '#down' do
    context 'index does not exist' do
      it 'creates temporary partial index on project_id' do
        migration.up

        expect { migration.down }.to change { migration.index_exists?(:services, :project_id, name: described_class::INDEX_NAME) }.from(false).to(true)
      end
    end

    context 'index already exists' do
      it 'skips creation of duplicated temporary partial index on project_id' do
        expect { migration.down }.not_to change { migration.index_exists?(:services, :project_id, name: described_class::INDEX_NAME) }
      end
    end
  end
end
