# frozen_string_literal: true

class LicenseScanningReportLicenseEntity < Grape::Entity
  expose :name
  expose(:classification) { |entity| { id: entity.id, name: entity.name, approval_status: entity.approval_status } }
  expose :dependencies, using: LicenseScanningReportDependencyEntity
  expose(:count) { |entity| entity.dependencies.count }
  expose :url
end
