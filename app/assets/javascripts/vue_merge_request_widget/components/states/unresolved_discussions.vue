<script>
import Mousetrap from 'mousetrap';
import { mapGetters, mapActions } from 'vuex';
import { GlButton, GlButtonGroup } from '@gitlab/ui';
import statusIcon from '../mr_widget_status_icon.vue';
import store from '~/mr_notes/stores';
import { n__ } from '../../../locale';

export default {
  name: 'UnresolvedDiscussions',
  store,
  components: {
    statusIcon,
    GlButton,
    GlButtonGroup,
  },
  props: {
    mr: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['unresolvedDiscussionsCount']),
    unresolvedText() {
      return n__(
        'mrWidget|Before this can be merged, 1 thread must be resolved.',
        'mrWidget|Before this can be merged, %d threads must be resolved.',
        this.unresolvedDiscussionsCount,
      );
    },
  },
  methods: {
    ...mapActions(['setCurrentDiscussionId']),
    jumpToFirstUnresolvedDiscussion() {
      this.setCurrentDiscussionId(null);
      Mousetrap.trigger('n');
    },
  },
};
</script>

<template>
  <div class="mr-widget-body media">
    <status-icon :show-disabled-button="true" status="warning" />
    <div class="media-body space-children">
      <span class="bold">{{ unresolvedText }}</span>
      <gl-button-group>
        <gl-button size="small" icon="comment-next" @click="jumpToFirstUnresolvedDiscussion">
          {{ s__('mrWidget|Jump to first unresolved thread') }}
        </gl-button>
        <gl-button
          v-if="mr.createIssueToResolveDiscussionsPath"
          :href="mr.createIssueToResolveDiscussionsPath"
          class="js-create-issue"
          size="small"
          icon="issue-new"
        >
          {{ s__('mrWidget|Resolve all threads in new issue') }}
        </gl-button>
      </gl-button-group>
    </div>
  </div>
</template>
