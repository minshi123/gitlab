# frozen_string_literal: true

class ProjectSetting < ApplicationRecord
  belongs_to :project, inverse_of: :project_setting

  enum squash_option: {
    never_squash: 0,
    always_squash: 1,
    enabled_with_default_on: 2,
    enabled_with_default_off: 3
  }, _prefix: 'squash'

  self.primary_key = :project_id

  def squash_enabled_by_default?
    %w[always_squash enabled_with_default_on].include?(squash_option)
  end

  def squash_readonly?
    %w[always_squash never_squash].include?(squash_option)
  end

  def always_squash?
    squash_always_squash?
  end

  def never_squash?
    squash_never_squash?
  end

  def self.where_or_create_by(attrs)
    where(primary_key => safe_find_or_create_by(attrs))
  end
end

ProjectSetting.prepend_if_ee('EE::ProjectSetting')
