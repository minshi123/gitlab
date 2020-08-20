# frozen_string_literal: true

class Projects::TodosController < Projects::ApplicationController
  include Gitlab::Utils::StrongMemoize
  include TodosActions

  before_action :authenticate_user!, only: [:create]

  private

  def issuable
    strong_memoize(:issuable) do
      case params[:issuable_type]
      when "issue"
        IssuesFinder.new(current_user, project_id: @project.id).find(params[:issuable_id])
      when "merge_request"
        MergeRequestsFinder.new(current_user, project_id: @project.id).find(params[:issuable_id])
      when "design"
        design = project.designs.find(params[:issuable_id])
        DesignManagement::DesignsFinder.new(design.issue, current_user).find(design.id)
      end
    end
  end
end
