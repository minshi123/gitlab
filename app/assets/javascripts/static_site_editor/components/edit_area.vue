<script>
import { GlTextarea } from '@gitlab/ui';

export default {
  components: {
    GlTextarea,
  },
  props: {
    value: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <gl-textarea :value="value" v-on="$listeners" />
</template>
