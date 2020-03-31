<script>
import { mapState } from 'vuex';
import { GlSkeletonLoader } from '@gitlab/ui';

import EditArea from './edit_area.vue';

export default {
  components: {
    EditArea,
    GlSkeletonLoader,
  },
  computed: {
    ...mapState(['content', 'isContentLoaded', 'isLoadingContent']),
  },
};
</script>
<template>
  <div>
    <gl-skeleton-loader v-if="isLoadingContent" />
    <edit-area v-if="isContentLoaded" :value="content" />
  </div>
</template>
