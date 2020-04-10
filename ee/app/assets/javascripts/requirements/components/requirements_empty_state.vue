<script>
import { GlEmptyState } from '@gitlab/ui';
import { __ } from '~/locale';

import { FilterState, FilterStateEmptyMessage } from '../constants';

export default {
  components: {
    GlEmptyState,
  },
  props: {
    filterBy: {
      type: String,
      required: true,
    },
    emptyStatePath: {
      type: String,
      required: true,
    },
    requirementsCount: {
      type: Object,
      required: true,
    },
  },
  computed: {
    emptyStateTitle() {
      return this.requirementsCount[FilterState.all]
        ? FilterStateEmptyMessage[this.filterBy]
        : __('Requirements allow you to create criteria to check your products against.');
    },
    emptyStateDescription() {
      return !this.requirementsCount[FilterState.all]
        ? __(
            `Requirements can be based on users, stakeholders, system, software
             or anything else you find important to capture. Create a requirement
             using "New requirement" button above while being in "Open" tab.`,
          )
        : null;
    },
  },
};
</script>

<template>
  <div class="requirements-empty-state-container">
    <gl-empty-state
      :svg-path="emptyStatePath"
      :title="emptyStateTitle"
      :description="emptyStateDescription"
    />
  </div>
</template>
