# frozen_string_literal: true

module Projects
  module Security
    class VulnerabilitiesController < Projects::ApplicationController
      include SecurityDashboardsPermissions
      include IssuableActions
      include RendersNotes

      before_action :vulnerability, except: :index

      alias_method :vulnerable, :project

      def index
        return render_404 unless Feature.enabled?(:first_class_vulnerabilities, project)

        @vulnerabilities = project.vulnerabilities.page(params[:page])
      end

      def show
        return render_404 unless Feature.enabled?(:first_class_vulnerabilities, project)

        pipeline = vulnerability.finding.pipelines.first
        @pipeline = pipeline if Ability.allowed?(current_user, :read_pipeline, pipeline)
      end

      private

      def vulnerability
        @issuable = @noteable = @vulnerability ||= vulnerable.vulnerabilities.find(params[:id])
        @vulnerability
      end

      alias_method :issuable, :vulnerability
      alias_method :noteable, :vulnerability
    end
  end
end
