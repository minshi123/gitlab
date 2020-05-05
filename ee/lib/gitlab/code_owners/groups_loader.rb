# frozen_string_literal: true

module Gitlab
  module CodeOwners
    class GroupsLoader
      def initialize(project, extractor)
        @project = project
        @extractor = extractor
      end

      def load_to(entries)
        groups = load_groups
        entries.each do |entry|
          entry.add_matching_groups_from(groups)
        end
      end

      private

      attr_reader :extractor, :project

      def load_groups
        return Group.none if extractor.names.empty?

        groups = project.invited_groups.where_full_path_in(extractor.names)

        if Feature.enabled?(:codeowners_match_ancestor_groups, project, default_enabled: false)
          group_list = groups.with_route.with_users.to_a

          if project.group
            ancestor_groups = project.group.self_and_ancestors.with_route.with_users

            # If the project.group's ancestor group(s) are listed as owners, add
            #   them to group_list
            #
            if (extractor.names & ancestor_groups.collect(&:full_path)).any?
              group_list << ancestor_groups
            end
          end

          group_list.flatten
        else
          groups.with_route.with_users
        end
      end
    end
  end
end
