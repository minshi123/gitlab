<script>
import GeoNodeForm from './geo_node_form.vue';

export default {
  name: 'GeoNodeFormApp',
  components: {
    GeoNodeForm,
  },
  props: {
    selectiveSyncTypes: {
      type: Array,
      required: true,
    },
    syncShardsOptions: {
      type: Array,
      required: true,
    },
    node: {
      type: Object,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <article class="geo-node-form-container">
    <h3 class="page-title">{{ node ? __('Edit Geo Node') : __('New Geo Node') }}</h3>
    <geo-node-form
      :node="node"
      :selective-sync-types="selectiveSyncTypes"
      :sync-shards-options="syncShardsOptions"
    />
  </article>
</template>
