<script>
import { GlSkeletonLoader } from '@gitlab/ui';

export default {
  components: {
    GlSkeletonLoader,
  },
  rows: {
    mobile: 5,
    desktop: 10,
  },
};
</script>

<template>
  <div>
    <div class="d-xs-flex flex-column d-md-none">
      <gl-skeleton-loader
        v-for="index in $options.rows.mobile"
        :key="index"
        :width="500"
        :height="215"
        preserve-aspect-ratio="xMinYMax meet"
      >
        <rect width="500" height="10" x="0" y="15" rx="4" />
        <rect width="500" height="10" x="0" y="55" rx="4" />
        <rect width="500" height="10" x="0" y="95" rx="4" />
        <rect width="500" height="10" x="0" y="135" rx="4" />
        <rect width="500" height="10" x="0" y="175" rx="4" />
      </gl-skeleton-loader>
    </div>

    <div class="d-none d-md-flex flex-column">
      <gl-skeleton-loader
        v-for="index in $options.rows.desktop"
        :key="index"
        :width="1000"
        :height="50"
        preserve-aspect-ratio="xMinYMax meet"
      >
        <rect width="220" height="10" x="0" y="20" rx="4" />
        <rect width="60" height="10" x="305" y="20" rx="4" />
        <rect width="60" height="10" x="535" y="20" rx="4" />
        <rect width="100" height="10" x="760" y="20" rx="4" />
        <rect width="30" height="30" x="960" y="10" rx="4" />
      </gl-skeleton-loader>
    </div>
  </div>
</template>
