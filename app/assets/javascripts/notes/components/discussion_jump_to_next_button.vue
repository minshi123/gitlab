<script>
import { GlTooltipDirective } from '@gitlab/ui';
import icon from '~/vue_shared/components/icon.vue';
import discussionNavigation from '../mixins/discussion_navigation';
import { mapState } from 'vuex';

export default {
  name: 'JumpToNextDiscussionButton',
  components: {
    icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [discussionNavigation],
  computed: {
    ...mapState('diffs', ['breakpoint']),
    isMobile() {
      return ['md', 'sm', 'xs'].includes(this.breakpoint);
    },
  },
  props: {
    fromDiscussionId: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div class="btn-group" role="group">
    <button
      ref="button"
      v-gl-tooltip
      class="btn btn-default discussion-next-btn"
      :title="s__('MergeRequests|Jump to next unresolved thread')"
      data-track-event="click_button"
      data-track-label="mr_next_unresolved_thread"
      data-track-property="click_next_unresolved_thread"
      @click="jumpToNextRelativeDiscussion(fromDiscussionId, isMobile)"
    >
      <icon name="comment-next" />
    </button>
  </div>
</template>
