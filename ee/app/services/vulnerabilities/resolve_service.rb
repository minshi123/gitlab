# frozen_string_literal: true

module Vulnerabilities
  class ResolveService
    include Gitlab::Allowable

    attr_reader :vulnerability, :user

    def initialize(user, vulnerability)
      @user = user
      @vulnerability = vulnerability
    end

    def execute
      raise Gitlab::Access::AccessDeniedError unless can?(@user, :admin_vulnerability, @vulnerability.project)

      @vulnerability.tap do |vulnerability|
        vulnerability.update(state: Vulnerability.states[:resolved], resolved_by: @user, resolved_at: Time.current)
        create_vulnerability_note
      end

    end

    private

    def create_vulnerability_note
      return unless vulnerability.state_previously_changed?

      SystemNoteService.change_vulnerability_state(vulnerability, user, 'resolved')
    end
  end
end
