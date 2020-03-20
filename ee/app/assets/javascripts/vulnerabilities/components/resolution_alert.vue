<script>
import { GlAlert } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  name: 'ResolutionAlert',
  components: {
    GlAlert,
  },
  data: () => ({
    isVisible: true,
  }),
  methods: {
    dismiss() {
      // TODO: We should make this a bit more sticky
      this.isVisible = false;
    },
  },
  RESOLUTION_MESSAGE: __(
    'The vulnerability is no longer detected. Verify the vulnerability has been remediated before changing its status.',
  ),
  RESOLUTION_TITLE: __('Vulnerability resolved in the default branch'),
};
</script>
<template>
  <gl-alert v-if="isVisible" :title="$options.RESOLUTION_TITLE" @dismiss="dismiss">
    {{ $options.RESOLUTION_MESSAGE }}
  </gl-alert>
</template>
