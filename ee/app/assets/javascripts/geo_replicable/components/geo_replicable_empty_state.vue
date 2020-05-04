<script>
import { mapState } from 'vuex';
import { GlEmptyState } from '@gitlab/ui';

export default {
  name: 'GeoReplicableEmptyState',
  components: {
    GlEmptyState,
  },
  props: {
    geoReplicableEmptySvgPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['replicableType']),
  },
};
</script>

<template>
  <gl-empty-state
    :title="sprintf(__('There are no %{replicableType} to show'), { replicableType })"
    :svg-path="geoReplicableEmptySvgPath"
  />
</template>
