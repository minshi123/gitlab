# frozen_string_literal: true

require 'spec_helper'

describe 'trials/_skip_trial.html.haml' do
  include ApplicationHelper

  context 'when glm_source' do
    it 'is not present then displays skip trial' do
      render 'trials/skip_trial'

      expect(rendered).to have_content("Skip Trial (Continue with Free Account)")
    end

    it 'is not gitlab.com then displays skip trial' do
      params[:glm_source] = 'about.gitlab.com'

      render 'trials/skip_trial'

      expect(rendered).to have_content("Skip Trial (Continue with Free Account)")
    end
  end

  context 'when glm_source' do
    it 'is not present then displays skip trial' do
      params[:glm_source] = 'gitlab.com'

      render 'trials/skip_trial'

      expect(rendered).to have_content("Go back to GitLab")
    end
  end
end
