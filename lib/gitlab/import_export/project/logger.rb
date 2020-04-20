# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Project
      class Logger < ::Gitlab::JsonLogger
        def self.file_name_noext
          'import_export'
        end
      end
    end
  end
end
