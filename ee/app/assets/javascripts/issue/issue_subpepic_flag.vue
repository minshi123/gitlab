<script>
/*
 * This component shows a subepic icon indicator if a list of issues are
 * filtered by epic id. An issue is member of a subepic when its epic id
 * is different than the filter epic id on the URL search parameters.
 */
import { __ } from '~/locale';
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
    epicId: {
      type: Number,
      required: false,
      default: () => {
        const urlParams = new URLSearchParams(window.location.search);
        const epicId = urlParams.get('epic_id');

        return parseInt(epicId, 10);
      },
    },
  },
  computed: {
    issueInSubepic() {
      const { epicId, issue } = this;
      const issueEpicId = issue.epic?.id;

      if (!epicId || !issueEpicId) {
        return false;
      }

      return epicId !== issueEpicId;
    },
    tooltipText() {
      return __('This issue is in a child epic of the filtered epic');
    },
  },
};
</script>

<template>
  <span v-if="issueInSubepic" v-gl-tooltip :title="tooltipText" class="d-inline-block ml-1">
    <gl-icon
      name="information-o"
      class="gl-display-block gl-text-blue-500 hover-text-primary-800"
    />
  </span>
</template>
