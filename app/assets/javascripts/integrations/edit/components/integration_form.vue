<script>
import ActiveToggle from './active_toggle.vue';
import JiraTriggerFields from './jira_trigger_fields.vue';

export default {
  name: 'IntegrationForm',
  components: {
    ActiveToggle,
    JiraTriggerFields,
  },
  props: {
    activeToggleProps: {
      type: Object,
      required: true,
    },
    triggerFieldsProps: {
      type: Object,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <active-toggle v-bind="activeToggleProps" />
    <jira-trigger-fields v-if="type == 'jira'" v-bind="triggerFieldsProps" />
  </div>
</template>
