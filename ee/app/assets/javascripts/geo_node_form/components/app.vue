<script>
import { __ } from '~/locale';
import GeoNodeForm from './geo_node_form.vue';

export default {
  name: 'GeoNodeFormApp',
  components: {
    GeoNodeForm,
  },
  props: {
    selectiveSyncTypes: {
      type: Object,
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
  computed: {
    pageTitle() {
      return this.node ? __('Edit Geo Node') : __('New Geo Node');
    },
    pillDetails() {
      return {
        color: this.node && this.node.primary ? 'bg-primary-400 text-white' : 'bg-secondary-100',
        label: this.node && this.node.primary ? __('Primary') : __('Secondary'),
      };
    },
  },
};
</script>

<template>
  <article class="geo-node-form-container">
    <div class="d-flex align-items-center">
      <h3 class="page-title">{{ pageTitle }}</h3>
      <span class="rounded-pill gl-font-sm px-2 py-1 ml-2" :class="pillDetails.color">{{
        pillDetails.label
      }}</span>
    </div>
    <geo-node-form v-bind="$props" />
  </article>
</template>
