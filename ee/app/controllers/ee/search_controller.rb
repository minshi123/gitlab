# frozen_string_literal: true

module EE
  module SearchController
    extend ::Gitlab::Utils::Override

    private

    override :override_snippet_scope
    def override_snippet_scope
      super unless search_service.use_elasticsearch?
    end
  end
end
