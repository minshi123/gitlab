<script>
import { __ } from '~/locale';
import { GlButton, GlFormGroup, GlFormSelect, GlIcon, GlLabel, GlTable } from '@gitlab/ui';

export default {
  name: 'JiraImportForm',
  components: {
    GlButton,
    GlFormGroup,
    GlFormSelect,
    GlIcon,
    GlLabel,
    GlTable,
  },
  currentUserAvatarUrl: gon.current_user_avatar_url,
  currentUsername: gon.current_username,
  props: {
    importLabel: {
      type: String,
      required: true,
    },
    issuesPath: {
      type: String,
      required: true,
    },
    jiraProjects: {
      type: Array,
      required: true,
    },
    value: {
      type: String,
      required: false,
      default: undefined,
    },
  },
  data() {
    return {
      selectState: null,
      fields: [
        {
          key: 'jiraUser',
          label: __('Jira users'),
        },
        {
          key: 'gitlabUser',
          label: __('GitLab users'),
        },
      ],
      items: [
        {
          jiraUser: '@alincoln',
          gitlabUser: '@alincoln',
        },
        {
          jiraUser: '@jryan',
          gitlabUser: '@jryan',
        },
        {
          jiraUser: '@adavies',
          gitlabUser: '@adavies',
        },
        {
          jiraUser: '@kbennet',
          gitlabUser: '@kbennet',
        },
      ],
    };
  },
  methods: {
    initiateJiraImport(event) {
      event.preventDefault();
      if (this.value) {
        this.hideValidationError();
        this.$emit('initiateJiraImport', this.value);
      } else {
        this.showValidationError();
      }
    },
    hideValidationError() {
      this.selectState = null;
    },
    showValidationError() {
      this.selectState = false;
    },
  },
};
</script>

<template>
  <div>
    <h3 class="page-title">{{ __('New Jira import') }}</h3>
    <hr />
    <form @submit="initiateJiraImport">
      <gl-form-group
        class="row align-items-center"
        :invalid-feedback="__('Please select a Jira project')"
        :label="__('Import from')"
        label-cols-sm="2"
        label-for="jira-project-select"
      >
        <gl-form-select
          id="jira-project-select"
          class="mb-2"
          :options="jiraProjects"
          :state="selectState"
          :value="value"
          @change="$emit('input', $event)"
        />
      </gl-form-group>

      <gl-form-group
        class="row align-items-center mb-4"
        :label="__('Issue label')"
        label-cols-sm="2"
        label-for="jira-project-label"
      >
        <gl-label
          id="jira-project-label"
          class="mb-2"
          background-color="#428BCA"
          :title="importLabel"
          scoped
        />
      </gl-form-group>

      <h4 class="mb-4">{{ __('Jira-GitLab user mapping template') }}</h4>

      <gl-table :fields="fields" :items="items" fixed variant="secondary" small>
        <template #cell(jiraUser)="data">
          <p class="gl-display-flex gl-justify-content-space-between gl-align-items-center m-0">
            <span>{{ data.value }}</span>
            <gl-icon name="arrow-right" />
          </p>
        </template>
      </gl-table>

      <div class="footer-block row-content-block d-flex justify-content-between">
        <gl-button type="submit" category="primary" variant="success" class="js-no-auto-disable">
          {{ __('Continue') }}
        </gl-button>
        <gl-button :href="issuesPath">{{ __('Cancel') }}</gl-button>
      </div>
    </form>
  </div>
</template>
