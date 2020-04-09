<script>
import { formatDate } from '~/lib/utils/datetime_utility';
import { __, sprintf } from '~/locale';

export default {
  name: 'JiraImportProgress',
  props: {
    illustration: {
      type: String,
      required: true,
    },
    importInitiator: {
      type: String,
      required: true,
    },
    importProject: {
      type: String,
      required: true,
    },
    importTime: {
      type: String,
      required: true,
    },
  },
  computed: {
    importInitiatorText() {
      return sprintf(__('Import started by: %{importInitiator}'), {
        importInitiator: this.importInitiator,
      });
    },
    importProjectText() {
      return sprintf(__('Jira project: %{importProject}'), {
        importProject: this.importProject,
      });
    },
    importTimeText() {
      return sprintf(__('Time of import: %{importTime}'), {
        importTime: formatDate(this.importTime),
      });
    },
  },
};
</script>

<template>
  <div class="empty-state">
    <div class="svg-content">
      <img :src="illustration" :alt="__('Jira import in progress illustration')" />
    </div>
    <div class="text-content d-flex flex-column align-items-center">
      <h4>{{ __('Import in progress') }}</h4>
      <p class="mb-0">{{ importInitiatorText }}</p>
      <p class="mb-0">{{ importTimeText }}</p>
      <p class="mb-2">{{ importProjectText }}</p>
      <a class="btn btn-success" href="../issues">
        {{ __('View issues') }}
      </a>
    </div>
  </div>
</template>
