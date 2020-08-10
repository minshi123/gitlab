# frozen_string_literal: true

class GroupDeployKey < Key
  self.table_name = 'group_deploy_keys'

  has_many :group_deploy_keys_groups, inverse_of: :group_deploy_key, dependent: :destroy # rubocop:disable Cop/ActiveRecordDependent
  has_many :groups, through: :group_deploy_keys_groups

  validates :user, presence: true

  scope :with_groups, -> { includes(group_deploy_keys_groups: :group) }
  scope :for_groups, ->(group_ids) do
    joins(:group_deploy_keys_groups).where('group_deploy_keys_groups.group_id IN (?)', group_ids).uniq
  end

  def type
    'DeployKey'
  end

  def group_deploy_keys_group_for(group)
    group_deploy_keys_groups.find_by(group: group)
  end
end
