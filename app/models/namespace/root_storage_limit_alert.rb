# frozen_string_literal: true

class Namespace::RootStorageLimitAlert
  include ActiveSupport::NumberHelper
  include Gitlab::Allowable

  INFO_USAGE_THRESHOLD = 0.5
  WARNING_USAGE_THRESHOLD = 0.75
  DANGER_USAGE_THRESHOLD = 0.95

  def initialize(namespace, user)
    @user = user
    @root_namespace = namespace.root_ancestor
    @root_storage_size = Namespace::RootStorageSize.new(root_namespace)
  end

  def level
    usage_ratio = root_storage_size.usage_ratio

    return if usage_ratio < INFO_USAGE_THRESHOLD

    return :info if usage_ratio < WARNING_USAGE_THRESHOLD

    return :warning if usage_ratio < DANGER_USAGE_THRESHOLD

    :danger
  end

  def message
    return unless alert_user?

    root_storage_size.above_size_limit? ? above_size_limit_message : explanation_message
  end

  def usage_message
    return unless alert_user?

    s_("You reached %{usage_in_percent} of %{namespace_name}'s capacity (%{used_storage} of %{storage_limit})" % current_usage_params)
  end

  private

  attr_reader :root_storage_size, :root_namespace, :user

  def alert_user?
    !level.nil? && Feature.enabled?(:namespace_storage_limit, root_namespace) && can?(user, :admin_namespace, root_namespace)
  end

  def explanation_message
    s_("If you reach 100%% storage capacity, you will not be able to: %{base_message}" % { base_message: base_message } )
  end

  def above_size_limit_message
    s_("%{namespace_name} is now read-only. You cannot: %{base_message}" % { namespace_name: root_namespace.name, base_message: base_message })
  end

  def base_message
    s_("push to your repository, create pipelines, create issues or add comments. To reduce storage capacity, delete unused repositories, artifacts, wikis, issues, and pipelines.")
  end

  def current_usage_params
    {
      usage_in_percent: number_to_percentage(root_storage_size.usage_ratio * 100, precision: 0),
      namespace_name: root_namespace.name,
      used_storage: formatted(root_storage_size.current_size),
      storage_limit: formatted(root_storage_size.limit)
    }
  end

  def formatted(number)
    number_to_human_size(number, delimiter: ',', precision: 2)
  end
end
