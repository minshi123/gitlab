# frozen_string_literal: true

class Packages::PypiMetadatum < ApplicationRecord
  belongs_to :package, -> { where(package_type: :pypi) }, inverse_of: :pypi_metadatum

  validates :package, presence: true
end
