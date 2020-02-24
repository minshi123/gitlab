# frozen_string_literal: true

# Returns design images
# Show the smaller sized thumbnail
# If `params[:sha]` is blank, they default
# to displaying the latest version, otherwise they
# display the version at `params[:sha]`
module Projects
  module DesignManagement
    module Designs
      class ResizedImageController < Projects::DesignManagement::DesignsController
        include SendFileUpload

        before_action :validate_size!

        skip_before_action :default_cache_headers, only: :show

        def show
          action = design.actions.most_recent.up_to_version(sha).first
          return render_404 unless action

          uploader = action.send(:"image_#{size}")
          return render_404 unless uploader.file # The image has not been processed

          if stale?(etag: action.cache_key)
            workhorse_set_content_type! # I think we need this?
            # Perhaps ping a workhorse dev to ask if this is workhorse accellerated?
            # do we need
            send_upload(uploader, attachment: design.filename)
          end
        end

        private

        # Also done in route, this allows controller testing
        def validate_size!
          render_404 unless ::DesignManagement::DESIGN_IMAGE_SIZES.include?(size)
        end

        # Size is validated within the route
        def size
          params[:id]
        end
      end
    end
  end
end
