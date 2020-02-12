# frozen_string_literal: true

class GroupHook < ProjectHook
  include CustomModelNaming
  include TriggerableHooks

  self.singular_route_key = :hook

  triggerable_hooks [
    :push_hooks,
    :tag_push_hooks,
    :issue_hooks,
    :confidential_issue_hooks,
    :note_hooks,
    :merge_request_hooks,
    :job_hooks,
    :pipeline_hooks,
    :wiki_page_hooks
  ]

  belongs_to :group

  clear_validators!
  validates :url, presence: true, addressable_url: true
  validate :validate_group_hook_limits_not_exceeded, on :create

  def pluralized_name
    _('Group Hooks')
  end

  private

  def validate_group_hook_limits_not_exceeded
    return unless group

    limit_name = :group_hooks
    limit_name = self.class.name.demodulize.tableize # Alternative

    relation = self.class.where(group: group) # Limit per group
    relation = self.class.where.not(group: nil) # Limit for all groups

    if group.actual_limits.exceeded?(limit_name, relation)
      errors.add(:base, _("Maximum number of %{name} (%{count}) exceeded") %
        { name: limit_name.humanize(capitalize: false), count: project.actual_limits.public_send(limit_name) }) # rubocop:disable GitlabSecurity/PublicSend
    end
  end

end
