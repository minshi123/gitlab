<script>
import { s__ } from '~/locale';
import { GlFilteredSearchToken } from '@gitlab/ui';

export default {
  components: {
    GlFilteredSearchToken,
  },
  data() {
    return {
      operators: [{ value: '=', description: 'is', default: 'true' }],
    };
  },
};
</script>
<template>
  <gl-filtered-search-token
    :operators="operators"
    v-bind="{ ...this.$props, ...this.$attrs }"
    v-on="$listeners"
  />
</template>
