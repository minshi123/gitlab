# frozen_string_literal: true

RSpec.shared_examples 'Insights page' do
  let_it_be(:user) { create(:user) }

  describe 'as a permitted user' do
    before(:context) do
      entity.add_maintainer(user)
    end

    before do
      sign_in(user)
    end

    context 'with correct license' do
      before do
        stub_licensed_features(insights: true)
      end

      it 'has correct title' do
        visit route

        expect(page).to have_gitlab_http_status(:ok)
        expect(page).to have_content('Insights')
      end

      describe 'navigation', :js do
        before do
          visit route
          wait_for_requests
        end

        describe 'hash fragment navigation' do
          let(:config) { entity.insights_config }
          let(:non_default_tab_id) { config.keys.last }
          let(:non_default_tab_title) { config[non_default_tab_id][:title] }
          let(:hash_fragment) { "#/#{non_default_tab_id}" }
          let(:route) { path + hash_fragment }

          it 'loads the correct page' do
            page.within(".insights-container") do
              expect(page).to have_content(non_default_tab_title)
            end
          end
        end

        it 'displays correctly when navigating back to insights' do
          expect(page).to have_content('Insights')

          visit root_path

          page.evaluate_script('window.history.back()')

          expect(page).to have_gitlab_http_status(:ok)
          expect(page).to have_content('Insights')
        end
      end

      describe 'when the feature flag is disabled globally' do
        before do
          stub_feature_flags(insights: false)
        end

        it 'returns 404' do
          visit route

          expect(page).to have_gitlab_http_status(:not_found)
        end
      end
    end

    describe 'without correct license' do
      before do
        stub_feature_flags(insights: { enabled: false, thing: entity })
        stub_licensed_features(insights: false)
      end

      it 'returns 404' do
        visit route

        expect(page).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
