# frozen_string_literal: true

# Shows Full LfsObject file
# Returns design images
module Projects
  module DesignManagement
    module Designs
      class RawImagesController < Projects::DesignManagement::DesignsController
        include SendsBlob

        skip_before_action :default_cache_headers, only: :show

        def show
          blob = design_repository.blob_at(sha, design.full_path)

          send_blob(design_repository, blob, { inline: false })
        end

        private

        def design_repository
          @design_repository ||= project.design_repository
        end
      end
    end
  end
end
