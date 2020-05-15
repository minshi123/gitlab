# frozen_string_literal: true

class PropagateIntegrationWorker
  include ApplicationWorker

  feature_category :integrations

  idempotent!

  def perform(integration_id, update_only_inherited)
    Admin::PropagateIntegrationService.propagate(
      integration: Service.find(integration_id),
      update_only_inherited: update_only_inherited
    )
  end
end
