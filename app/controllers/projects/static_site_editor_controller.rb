# frozen_string_literal: true

class Projects::StaticSiteEditorController < Projects::ApplicationController
  include ExtractsPath
  layout 'fullscreen'

  prepend_before_action :authenticate_user!, only: [:show]
  before_action :assign_ref_and_path, only: [:show]
  before_action :check_user_permissions, only: [:show]

  def show
    @config = Gitlab::StaticSiteEditor::Config.new(@repository, @ref, @path, params[:return_url])
  end

  private

  def assign_ref_and_path
    @ref, @path = extract_ref(params[:id])

    render_404 if @ref.blank? || @path.blank?
  end

  def check_user_permissions
    render_404 unless can_collaborate_with_project?(project, ref: @ref)
  end
end
