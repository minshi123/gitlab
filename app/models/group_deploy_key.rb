# frozen_string_literal: true

class GroupDeployKey < Key
  self.table_name = 'group_deploy_keys'

  has_many :group_deploy_keys_groups, inverse_of: :group_deploy_key, dependent: :destroy # rubocop:disable Cop/ActiveRecordDependent
  has_many :groups, through: :group_deploy_keys_groups

  validates :user, presence: true

  def type
    'DeployKey'
  end

  def group_deploy_keys_group_for(group)
    group_deploy_keys_groups.find_by(group: group)
  end
end
