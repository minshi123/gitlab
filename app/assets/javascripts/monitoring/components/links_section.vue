<script>
import { mapState } from 'vuex';
import { GlIcon, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
    GlLink,
  },
  computed: {
    ...mapState('monitoringDashboard', ['links']),
  },
};
</script>
<template>
  <div
    ref="linksSection"
    class="d-sm-flex flex-sm-wrap mt-2 pt-2 pr-1 pb-0 pl-2 links-section bg-gray-light border border-radius-default"
  >
    <div
      v-for="(link, key) in links"
      :key="key"
      class="mb-1 pr-2 d-flex d-sm-block text-break-word hover-text-primary-500"
    >
      <gl-icon name="link" />
      <gl-link
        :href="link.url"
        class="text-plain align-text-bottom hover-text-primary-500 text-decoration-none"
        >{{ link.title }}</gl-link
      >
    </div>
  </div>
</template>
