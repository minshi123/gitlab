# frozen_string_literal: true

class GroupDeployKeyEntity < Grape::Entity
  expose :id
  expose :user_id
  expose :title
  expose :fingerprint
  expose :fingerprint_sha256
  expose :created_at
  expose :updated_at
  expose :group_deploy_keys_groups, using: GroupDeployKeysGroupEntity do |group_deploy_key|
    group_deploy_key.group_deploy_keys_groups.select do |deploy_key_group|
      Ability.allowed?(options[:user], :read_group, deploy_key_group.group)
    end
  end
  expose :can_edit

  private

  def can_edit
    Ability.allowed?(options[:user], :update_group_deploy_key, object) ||
      Ability.allowed?(
        options[:user],
        :update_group_deploy_key_for_group,
        object.group_deploy_keys_group_for(option[:group])
      )
  end
end
