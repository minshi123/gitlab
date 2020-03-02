# frozen_string_literal: true

class NotePolicy < BasePolicy
  delegate { @subject.resource_parent }
  delegate { @subject.noteable if DeclarativePolicy.has_policy?(@subject.noteable) }

  condition(:is_author) { @user && @subject.author == @user }
  condition(:is_noteable_author) { @user && @subject.noteable.author_id == @user.id }

  condition(:editable, scope: :subject) { @subject.editable? }

  condition(:can_read_noteable) { can?(:"read_#{@subject.noteable_ability_name}") }

  condition(:is_visible) { @subject.system_note_with_references_visible_for?(@user) }

  condition(:confidential, scope: :subject) { @subject.confidential? }

  condition(:can_read_confidential) do
    access_level >= Gitlab::Access::REPORTER ||
    @user && @subject.noteable.assignee_or_author?(@user)
  end

  rule { ~editable }.prevent :admin_note

  # If user can't read the issue/MR/etc then they should not be allowed to do anything to their own notes
  rule { ~can_read_noteable }.policy do
    prevent :read_note
    prevent :admin_note
    prevent :resolve_note
    prevent :award_emoji
  end

  rule { is_author }.policy do
    enable :read_note
    enable :admin_note
    enable :resolve_note
  end

  rule { ~is_visible }.policy do
    prevent :read_note
    prevent :admin_note
    prevent :resolve_note
    prevent :award_emoji
  end

  rule { is_noteable_author }.policy do
    enable :resolve_note
  end

  rule { confidential & ~can_read_confidential }.policy do
    prevent :read_note
    prevent :admin_note
    prevent :resolve_note
    prevent :award_emoji
  end

  def access_level
    return -1 if @user.nil?

    lookup_access_level!
  end

  def lookup_access_level!
    return ::Gitlab::Access::REPORTER if alert_bot?

    # NOTE: max_member_access has its own cache
    @subject.project.team.max_member_access(@user.id)
  end
end
