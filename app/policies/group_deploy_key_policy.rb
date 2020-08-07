# frozen_string_literal: true

class GroupDeployKeyPolicy < BasePolicy
  condition(:user_owns_group_deploy_key) { @subject.user_id == @user.id }

  rule { user_owns_group_deploy_key }.enable :update_group_deploy_key
end
