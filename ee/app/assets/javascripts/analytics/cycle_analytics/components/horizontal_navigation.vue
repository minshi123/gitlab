<script>
import { GlPath } from '@gitlab/ui';

export default {
  name: 'HorizontalNavigation',
  components: {
    GlPath,
  },
  props: {
    stages: {
      type: Array,
      required: true,
    },
  },
  methods: {
    onStageClick() {
      // TODO: Emit stage here or trigger action which updates state?
    },
  },
};
</script>
<template>
  <gl-path :items="stages" @selected="onStageClick" />
</template>
