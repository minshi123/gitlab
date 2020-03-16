# frozen_string_literal: true

module ElasticsearchIndexedContainer
  extend ActiveSupport::Concern

  included do
    after_commit :index, on: :create
    after_commit :delete_from_index, on: :destroy
    after_commit :drop_target_ids_cache!, on: [:create, :destroy]

    def drop_target_ids_cache!
      Rails.cache.delete self.class.target_ids_cache_key
    end
  end

  class_methods do
    def target_ids_cache_key
      [self.name.underscore.to_sym, :target_ids]
    end

    def target_ids
      Rails.cache.fetch target_ids_cache_key do
        pluck(target_attr_name)
      end
    end

    def remove_all(except: [])
      self.where.not(target_attr_name => except).each_batch do |batch, _index|
        batch.destroy_all # #rubocop:disable Cop/DestroyAll
      end
    end
  end
end
