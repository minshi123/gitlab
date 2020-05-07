<script>
import { GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
  },
  props: {
    icon: {
      type: String,
      required: true,
    },
    className: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>
<template>
  <button class="text-dark" :class="className">
    <gl-icon :name="icon" />
  </button>
</template>
