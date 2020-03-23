# frozen_string_literal: true

module Projects
  module Security
    module Vulnerabilities
      class NotesController < Projects::ApplicationController
        extend ::Gitlab::Utils::Override

        include SecurityDashboardsPermissions
        include NotesActions
        include NotesHelper
        include ToggleAwardEmoji

        before_action :not_found, unless: :first_class_vulnerabilities_enabled?
        before_action :vulnerability
        before_action :authorize_create_note!, only: [:create]

        private

        def first_class_vulnerabilities_enabled?
          Feature.enabled?(:first_class_vulnerabilities, project)
        end

        alias_method :vulnerable, :project

        def note
          @note ||= noteable.notes.find(params[:id])
        end
        alias_method :awardable, :note

        def vulnerability
          @vulnerability ||= @project.vulnerabilities.find_by_id(params[:vulnerability_id])

          return render_404 unless can?(current_user, :read_vulnerability, @vulnerability)

          @vulnerability
        end
        alias_method :noteable, :vulnerability

        def finder_params
          params.merge(last_fetched_at: last_fetched_at, target_id: vulnerability.id, target_type: 'vulnerability', project: @project)
        end

        def authorize_create_note!
          access_denied! unless can?(current_user, :create_note, noteable)
        end

        def note_serializer
          VulnerabilityNoteSerializer.new(project: project, noteable: noteable, current_user: current_user)
        end

        def discussion_serializer
          DiscussionSerializer.new(project: project, noteable: noteable, current_user: current_user, note_entity: VulnerabilityNoteEntity)
        end
      end
    end
  end
end
