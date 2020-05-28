<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: { GlLink },
  props: {
    href: { type: String, required: true },
    target: { type: String, required: false, default: '_blank' },
  },
};
</script>

<template functional>
  <gl-link :href="props.href" :target="props.target">{{ __('More information') }}</gl-link>
</template>
