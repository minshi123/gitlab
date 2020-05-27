<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
  props: {
    iterations: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
};
</script>

<template>
  <div class="milestones">
    <ul v-if="iterations.length > 0" class="content-list">
      <li v-for="iteration in iterations" :key="iteration.id" class="milestone">
        <gl-link :href="iteration.webPath"
          ><strong>{{ iteration.title }}</strong></gl-link
        >
        <p class="text-secondary">{{ iteration.startDate }} - {{ iteration.dueDate }}</p>
      </li>
    </ul>
    <div v-else class="nothing-here-block">
      {{ __('No iterations to show') }}
    </div>
  </div>
</template>
