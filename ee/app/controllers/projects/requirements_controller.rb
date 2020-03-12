# frozen_string_literal: true

class Projects::RequirementsController < Projects::ApplicationController
  def index
    respond_to do |format|
      format.html
    end
  end
end
