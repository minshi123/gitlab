<script>
import getJiraProjects from '../queries/getJiraProjects.query.graphql';
import JiraImportSetup from './jira_import_setup.vue';

export default {
  name: 'JiraImportApp',
  components: {
    JiraImportSetup,
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
  data() {
    return {
      isImportInProgress: false,
    };
  },
  apollo: {
    getJiraImports: {
      query: getJiraProjects,
      variables() {
        return {
          fullPath: this.projectPath,
        };
      },
      update: data => data.project.jiraImports,
    },
  },
};
</script>

<template>
  <div>
    <jira-import-setup v-if="!isJiraConfigured" />
    <div v-else></div>
  </div>
</template>
