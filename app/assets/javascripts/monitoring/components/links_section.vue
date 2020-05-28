<script>
/**
 * This component generates user-defined links in the
 * dashboard yml file. However, this component will be
 * used in the metrics dashboard after
 * https://gitlab.com/gitlab-org/gitlab/-/merge_requests/32895
 */
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
    class="d-sm-flex flex-sm-wrap mt-3 pl-2 pr-2 pt-2 pb-2 bg-gray-light border border-radius-default links-section"
  >
    <div
      v-for="(link, key) in links"
      :key="key"
      class="mb-1 pr-3 d-flex d-sm-block text-break-word"
    >
      <gl-link :href="link.url" class="link-hover text-plain text-decoration-none"
        ><gl-icon name="link" class="link-icon align-text-bottom mr-1" />{{ link.title }}
      </gl-link>
    </div>
  </div>
</template>
