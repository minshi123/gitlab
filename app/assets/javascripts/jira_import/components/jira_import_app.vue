<script>
import { GlFormGroup, GlFormInput, GlFormSelect } from '@gitlab/ui';
import getState from '../queries/getState.query.graphql';

export default {
  name: 'JiraImportApp',
  components: {
    GlFormGroup,
    GlFormInput,
    GlFormSelect,
  },
  apollo: {
    jiraImports: {
      query: getState,
      update: data => data.project.jiraImports.nodes,
    },
  },
};
</script>

<template>
  <div>
    <h3>{{ __('Import Jira issues') }}</h3>
    <form>
      <gl-form-group
        :label="__('Which Jira project would you like to import issues from?')"
        label-cols-sm="5"
        label-for="jira-project"
      >
        <gl-form-select id="jira-project"  />
      </gl-form-group>

      <p>{{ __('Create a unique label for these issues') }}</p>

      <gl-form-group
        :label="__('Title')"
        label-cols-sm="2"
        label-for="label-title"
        class="offset-sm-1"
      >
        <gl-form-input id="label-title" />
      </gl-form-group>

      <gl-form-group
        :label="__('Description')"
        label-cols-sm="2"
        label-for="label-description"
      >
        <gl-form-input id="label-description" />
      </gl-form-group>

      <gl-form-group
        :label="__('Background color')"
        label-cols-sm="2"
        label-for="label-color"
      >
        <gl-form-input id="label-color" />
      </gl-form-group>

      <p>{{ __('We will create a new GitLab issue for each based on the following template:') }}</p>
    </form>
  </div>
</template>
