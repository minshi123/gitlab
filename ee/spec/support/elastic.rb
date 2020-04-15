# frozen_string_literal: true

RSpec.configure do |config|
  helper = Gitlab::Elastic::Helper.new

  config.before(:each, :elastic) do
    Elastic::ProcessBookkeepingService.clear_tracking!
    helper.delete_index if helper.index_exists?
    helper.create_empty_index
  end

  config.after(:each, :elastic) do
    helper.delete_index if helper.index_exists?
    Elastic::ProcessBookkeepingService.clear_tracking!
  end

  config.include ElasticsearchHelpers, :elastic
end
