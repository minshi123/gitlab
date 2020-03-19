# frozen_string_literal: true

module Projects
  module Security
    class VulnerabilitiesController < Projects::ApplicationController
      include SecurityDashboardsPermissions
      include IssuableActions
      include RendersNotes

      before_action :not_found, unless: :first_class_vulnerabilities_enabled?
      before_action :vulnerability, except: :index

      alias_method :vulnerable, :project

      def index
        @vulnerabilities = project.vulnerabilities.page(params[:page])
      end

      def show
        pipeline = vulnerability.finding.pipelines.first
        @pipeline = pipeline if Ability.allowed?(current_user, :read_pipeline, pipeline)
      end

      private

      def first_class_vulnerabilities_enabled?
        Feature.enabled?(:first_class_vulnerabilities, project)
      end

      def vulnerability
        @issuable = @noteable = @vulnerability ||= vulnerable.vulnerabilities.find(params[:id])
        @vulnerability
      end

      alias_method :issuable, :vulnerability
      alias_method :noteable, :vulnerability
    end
  end
end
