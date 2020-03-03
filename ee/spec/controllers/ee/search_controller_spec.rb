# frozen_string_literal: true

require 'spec_helper'

describe SearchController do
  describe 'GET #show' do
    context 'snippet search' do
      context 'when Elasticsearch is enabled', :elastic do
        before do
          stub_ee_application_setting(search_using_elasticsearch: true, elasticsearch_search: true, elasticsearch_indexing: true)
        end

        it 'does not force title search' do
          get :show, params: { scope: 'snippet_blobs', snippets: 'true', search: 'foo' }

          expect(assigns[:scope]).to eq('snippet_blobs')
        end
      end
    end
  end
end
