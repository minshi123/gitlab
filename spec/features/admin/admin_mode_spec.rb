# frozen_string_literal: true

require 'spec_helper'

describe 'Admin updates settings', :clean_gitlab_redis_shared_state, :do_not_mock_admin_mode do
  let(:admin) { create(:admin) }

  context 'feature flag :user_mode_in_session is enabled', :request_store do
    before do
      sign_in(admin)
    end

    context 'when in admin_mode' do
      before do
        gitlab_enable_admin_mode_sign_in(admin)
      end

      it 'can leave admin mode', :js do
        page.within('.navbar-sub-nav') do
          click_on 'Leave Admin Mode'

          expect(page).to have_link(href: new_admin_session_path)
        end
      end

      context 'on a read-only instance' do
        before do
          allow(Gitlab::Database).to receive(:read_only?).and_return(true)
        end

        it 'can leave admin mode', :js do
          page.within('.navbar-sub-nav') do
            click_on 'Leave Admin Mode'

            expect(page).to have_link(href: new_admin_session_path)
          end
        end
      end
    end

    context 'when not in admin mode' do
      it 'can enter admin mode' do
        visit new_admin_session_path

        fill_in 'password', with: admin.password

        click_button 'Enter Admin Mode'

        expect(page).to have_current_path(admin_root_path)
      end

      context 'on a read-only instance' do
        before do
          allow(Gitlab::Database).to receive(:read_only?).and_return(true)
        end

        it 'can enter admin mode' do
          visit new_admin_session_path

          fill_in 'password', with: admin.password

          click_button 'Enter Admin Mode'

          expect(page).to have_current_path(admin_root_path)
        end
      end
    end
  end

  context 'feature flag :user_mode_in_session is disabled' do
    before do
      stub_feature_flags(user_mode_in_session: false)
      sign_in(admin)
    end

    it 'shows no admin mode buttons in navbar' do
      visit admin_root_path

      page.within('.navbar-sub-nav') do
        expect(page).not_to have_link(href: new_admin_session_path)
        expect(page).not_to have_link(href: destroy_admin_session_path)
      end
    end
  end
end
