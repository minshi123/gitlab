# frozen_string_literal: true

class Admin::Geo::ApplicationController < Admin::ApplicationController
  helper ::EE::GeoHelper

  protected

  def check_license!
    unless Gitlab::Geo.license_allows?
      @license = 'core'

      unless License.current.nil?
        @license = License.current.plan
      end

      flash[:tip] = _("<svg class=\"s16 gl-alert-icon gl-alert-icon-no-title\"><use xmlns:xlink=\"http://www.w3.org/1999/xlink\" xlink:href=\"/assets/icons.svg#%{icon}\"></use></svg> <p class=\"ml-4 mb-0\">This GitLab instance is licensed at the <span class=\"text-capitalize\">%{license}</span> tier. Geo is only available for users who have at least a Premium license.<br />%{license_link}</p>").html_safe % {
        license: @license,
        license_link: view_context.link_to(_('Manage your license'), admin_license_path, { class: "btn btn-info mt-3" }),
        icon: 'bulb'
      }

      redirect_to admin_license_path
    end
  end
end
