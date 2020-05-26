<script>
import { GlButton, GlTab, GlTabs } from '@gitlab/ui';
import IterationsList from './iterations_list.vue';
import GroupIterationQuery from '../queries/group_iteration.query.graphql';

export default {
  components: {
    IterationsList,
    GlButton,
    GlTab,
    GlTabs,
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
    canAdmin: {
      type: Boolean,
      required: false,
      default: false,
    },
    newIterationPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  apollo: {
    iterations: {
      query: GroupIterationQuery,
      update: data => data.group.iterations.nodes,
      variables() {
        return {
          fullPath: this.groupPath,
          state: this.state,
        };
      },
    },
  },
  data() {
    return {
      iterations: [],
      tabIndex: 0,
    };
  },
  computed: {
    loading() {
      return this.$apollo.queries.iterations.loading;
    },
    state() {
      switch (this.tabIndex) {
        default:
        case 0:
          return 'opened';
        case 1:
          return 'closed';
        case 2:
          return 'all';
      }
    },
  },
};
</script>

<template>
  <gl-tabs v-model="tabIndex">
    <gl-tab>
      <template #title>
        {{ s__('Open') }}
      </template>
      <iterations-list :iterations="iterations" :loading="loading" />
    </gl-tab>
    <gl-tab>
      <template #title>
        {{ s__('Closed') }}
      </template>
      <iterations-list :iterations="iterations" :loading="loading" />
    </gl-tab>
    <gl-tab>
      <template #title>
        {{ s__('All') }}
      </template>
      <iterations-list :iterations="iterations" :loading="loading" />
    </gl-tab>
    <template v-if="canAdmin" #tabs-end>
      <li class="gl-ml-auto gl-display-flex gl-align-items-center">
        <gl-button variant="success" :href="newIterationPath">{{ __('New iteration') }}</gl-button>
      </li>
    </template>
  </gl-tabs>
</template>
