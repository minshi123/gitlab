# frozen_string_literal: true
#
class ProjectSecuritySetting < ApplicationRecord
  belongs_to :project, inverse_of: :security_setting
end
