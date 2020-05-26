<script>
import { GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlLoadingIcon,
  },
  props: {
    iterations: {
      type: Array,
      required: false,
      default: () => [],
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <div class="milestones">
    <div v-if="loading" class="gl-my-5">
      <gl-loading-icon size="lg" />
    </div>
    <ul v-else-if="iterations.length > 0" class="content-list">
      <li v-for="iteration in iterations" :key="iteration.id" class="milestone milestone-open">
        <a :href="iteration.webPath"
          ><strong>{{ iteration.title }}</strong></a
        >
        <p class="text-secondary">{{ iteration.startDate }} - {{ iteration.dueDate }}</p>
      </li>
    </ul>
    <div v-else class="nothing-here-block">
      {{ __('No iterations to show') }}
    </div>
  </div>
</template>
