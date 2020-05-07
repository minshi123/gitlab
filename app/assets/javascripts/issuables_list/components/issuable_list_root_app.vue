<script>
import { GlAlert, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import getJiraImportDetailsQuery from '~/jira_import/queries/get_jira_import_details.query.graphql';

// TODO ONLY SHOW FOR ADMIN

export default {
  name: 'IssuableListRoot',
  components: {
    GlAlert,
  },
  props: {
    isJiraConfigured: {
      type: Boolean,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
  },
  apollo: {
    jiraImportDetails: {
      query: getJiraImportDetailsQuery,
      variables() {
        return {
          fullPath: this.projectPath,
        };
      },
      update: ({ project }) => ({
        status: project.jiraImportStatus,
        imports: project.jiraImports.nodes,
      }),
      skip() {
        return !this.isJiraConfigured;
      },
    },
  },
};
</script>

<template>
  <div>
    <gl-alert>{{ __('Import in progress. Refresh page to see newly added issues') }}</gl-alert>
    <gl-alert variant="success">{{
      __('39 issues successfully imported with the label jira-import::KEY-1')
    }}</gl-alert>
  </div>
</template>
