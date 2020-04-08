<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
  props: {
    returnUrl: {
      type: String,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <div class="d-flex justify-content-between align-items-center">
    <div>
      <h3>{{ s__('StaticSiteEditor|Edit content') }}</h3>
    </div>
    <gl-link v-if="returnUrl" ref="returnUrlLink" :href="returnUrl">
      {{ s__('StaticSiteEditor|Go back') }}</gl-link
    >
  </div>
</template>
