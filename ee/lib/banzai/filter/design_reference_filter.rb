# frozen_string_literal: true

module Banzai
  module Filter
    class DesignReferenceFilter < AbstractReferenceFilter
      Identifier = Struct.new(:issue_iid, :filename, keyword_init: true)

      # This filter must be enabled by setting the following flags:
      #  - design_management
      #  - design_management_reference_filter_gfm_pipeline
      def call
        return doc unless enabled?

        super
      end

      def find_object(project, identifier)
        records_per_parent[project][identifier]
      end

      def parent_records(project, identifiers)
        filenames_by_issue_iid = identifiers
          .group_by(&:issue_iid)
          .transform_values { |vs| vs.map(&:filename) }

        issues(project, filenames_by_issue_iid.keys).flat_map do |issue|
          designs(issue, filenames_by_issue_iid[issue.iid])
        end
      end

      def parent_type
        :project
      end

      def url_for_object(design, project)
        path_options = { vueroute: design.filename }
        Gitlab::Routing.url_helpers.designs_project_issue_path(project, design.issue, path_options)
      end

      def data_attributes_for(_text, _project, design, **_kwargs)
        super.merge(issue: design.issue_id)
      end

      def self.object_class
        ::DesignManagement::Design
      end

      def self.object_sym
        :design
      end

      def self.parse_symbol(raw, match_data)
        filename = if efn = match_data[:escaped_filename]
                     efn.gsub(/(\\ \\ | \\ ")/x) { |x| x[1] }
                   elsif b64_name = match_data[:base_64_encoded_name]
                     Base64.decode64(b64_name)
                   elsif name = match_data[:simple_file_name]
                     name
                   else
                     raise "Unexpected name format: #{raw}"
                   end

        Identifier.new(filename: filename, issue_iid: match_data[:issue].to_i)
      end

      def record_identifier(design)
        Identifier.new(filename: design.filename, issue_iid: design.issue.iid)
      end

      private

      def designs(issue, filenames)
        DesignManagement::DesignsFinder.new(issue, current_user, filenames: filenames)
          .execute
      end

      def issues(project, iids)
        IssuesFinder.new(current_user, project_id: project.id, iids: iids).execute
      end

      def enabled?
        features = %i[
          design_management
          design_management_reference_filter_gfm_pipeline
        ]

        features.all? { |name| ::Feature.enabled?(name) }
      end
    end
  end
end
