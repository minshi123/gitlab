# frozen_string_literal: true

class Projects::SnippetsController < Projects::Snippets::ApplicationController
  include SnippetsActions
  include ToggleAwardEmoji
  include SpammableActions

  before_action :check_snippets_available!

  before_action :snippet, only: [:show, :edit, :destroy, :update, :raw, :toggle_award_emoji, :mark_as_spam]

  before_action :authorize_create_snippet!, only: [:new, :create]
  before_action :authorize_read_snippet!, except: [:new, :create, :index]
  before_action :authorize_update_snippet!, only: [:edit, :update]
  before_action :authorize_admin_snippet!, only: [:destroy]

  def index
    @snippet_counts = ::Snippets::CountService
      .new(current_user, project: @project)
      .execute

    @snippets = SnippetsFinder.new(current_user, project: @project, scope: params[:scope])
      .execute
      .page(params[:page])
      .inc_author

    return if redirect_out_of_range(@snippets)

    @noteable_meta_data = noteable_meta_data(@snippets, 'Snippet')
  end

  def new
    @snippet = @noteable = @project.snippets.build
  end

  def create
    create_params = snippet_params.merge(spammable_params)
    service_response = ::Snippets::CreateService.new(project, current_user, create_params).execute
    @snippet = service_response.payload[:snippet]

    handle_repository_error(:new)
  end

  protected

  alias_method :awardable, :snippet
  alias_method :spammable, :snippet

  def spammable_path
    project_snippet_path(@project, @snippet)
  end

  def snippet_params
    params.require(:project_snippet).permit(:title, :content, :file_name, :private, :visibility_level, :description)
  end
end
