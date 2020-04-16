<script>
import icon from '~/vue_shared/components/icon.vue';
import GeoNodeLastUpdated from './geo_node_last_updated.vue';
import { HEALTH_STATUS_ICON, HEALTH_STATUS_CLASS } from '../constants';

export default {
  components: {
    icon,
    GeoNodeLastUpdated,
  },
  props: {
    status: {
      type: String,
      required: true,
    },
    nodeDetails: {
      type: Object,
      required: true,
    },
  },
  computed: {
    healthCssClass() {
      return HEALTH_STATUS_CLASS[this.status.toLowerCase()];
    },
    statusIconName() {
      return HEALTH_STATUS_ICON[this.status.toLowerCase()];
    },
  },
};
</script>

<template>
  <div class="mt-2 detail-section-item">
    <div class="text-secondary-700 node-detail-title">{{ s__('GeoNodes|Health status') }}</div>
    <div class="d-flex align-items-center">
      <div
        :class="healthCssClass"
        class="rounded-pill d-inline-flex align-items-center px-2 py-1 my-1 mr-2"
      >
        <icon :size="16" :name="statusIconName" />
        <span class="status-text ml-1 bold"> {{ status }} </span>
      </div>
      <geo-node-last-updated :node-details="nodeDetails" />
    </div>
  </div>
</template>
