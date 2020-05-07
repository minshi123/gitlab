<script>
import { GlAlert, GlLabel } from '@gitlab/ui';
import getJiraImportDetailsQuery from '~/jira_import/queries/get_jira_import_details.query.graphql';
import { calculateJiraImportLabel, IMPORT_STATE, isInProgress } from '~/jira_import/utils';

export default {
  name: 'IssuableListRoot',
  components: {
    GlAlert,
    GlLabel,
  },
  props: {
    canEdit: {
      type: Boolean,
      required: true,
    },
    isJiraConfigured: {
      type: Boolean,
      required: true,
    },
    issuesPath: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isFinishedAlertShowing: true,
      isInProgressAlertShowing: true,
    };
  },
  apollo: {
    jiraImport: {
      query: getJiraImportDetailsQuery,
      variables() {
        return {
          fullPath: this.projectPath,
        };
      },
      update: ({ project }) => ({
        isInProgress: isInProgress(project.jiraImportStatus),
        isFinished: project.jiraImportStatus === IMPORT_STATE.FINISHED,
        label: calculateJiraImportLabel(project.jiraImports.nodes),
      }),
      skip() {
        return !this.isJiraConfigured || !this.canEdit;
      },
    },
  },
  computed: {
    labelTarget() {
      return `${this.issuesPath}?label_name[]=${encodeURIComponent(this.jiraImport.label)}`;
    },
    shouldShowFinishedAlert() {
      return this.isFinishedAlertShowing && this.jiraImport?.isFinished;
    },
    shouldShowInProgressAlert() {
      return this.isInProgressAlertShowing && this.jiraImport?.isInProgress;
    },
  },
  methods: {
    hideFinishedAlert() {
      this.isFinishedAlertShowing = false;
    },
    hideInProgressAlert() {
      this.isInProgressAlertShowing = false;
    },
  },
};
</script>

<template>
  <div class="issuable-list-root">
    <gl-alert v-if="shouldShowFinishedAlert" variant="success" @dismiss="hideFinishedAlert">
      {{ __('39 issues successfully imported with the label') }}
      <gl-label
        background-color="#428BCA"
        scoped
        size="sm"
        :target="labelTarget"
        :title="jiraImport.label"
      />
    </gl-alert>
    <gl-alert v-if="shouldShowInProgressAlert" @dismiss="hideInProgressAlert">
      {{ __('Import in progress. Refresh page to see newly added issues') }}
    </gl-alert>
  </div>
</template>
