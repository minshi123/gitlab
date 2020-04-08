<script>
import Icon from '~/vue_shared/components/icon.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import HistoryComment from './history_comment.vue';
import { __ } from '~/locale';

export default {
  components: {
    Icon,
    TimeAgoTooltip,
    HistoryComment,
  },
  props: {
    discussion: {
      type: Object,
      required: true,
    },
  },
  data: () => ({
    text: '',
  }),
  computed: {
    systemNote() {
      return this.discussion.notes.find(x => x.system === true);
    },
    comments() {
      return this.discussion.notes.filter(x => x !== this.systemNote);
    },
    hasComments() {
      return this.comments.length;
    },
  },
  methods: {
    addComment(comment) {
      this.discussion.notes.push(comment);
    },
    removeComment(comment) {
      const index = this.discussion.notes.indexOf(comment);

      if (index > -1) {
        this.discussion.notes.splice(index, 1);
      }
    },
  },
  actionButtons: [
    {
      iconName: 'pencil',
      emit: 'showCommentTextArea',
      title: __('Edit Comment'),
    },
    {
      iconName: 'remove',
      emit: 'showDismissalDeleteButtons',
      title: __('Delete Comment'),
    },
  ],
};
</script>

<template>
  <li class="card border-bottom system-note p-0">
    <div class="note-header-info mx-3 my-4">
      <div class="timeline-icon mr-0">
        <icon :name="systemNote.system_note_icon_name" />
      </div>

      <a
        :href="systemNote.author.path"
        class="js-user-link ml-3"
        :data-user-id="systemNote.author.id"
      >
        <strong class="note-header-author-name">{{ systemNote.author.name }}</strong>
        <span
          v-if="systemNote.author.status_tooltip_html"
          v-html="systemNote.author.status_tooltip_html"
        ></span>
        <span class="note-headline-light">@{{ systemNote.author.username }}</span>
      </a>
      <span class="note-headline-light">
        {{ systemNote.note }}
        <time-ago-tooltip :time="systemNote.updated_at" />
      </span>
    </div>

    <template v-if="hasComments">
      <hr class="mx-3" />
      <history-comment
        v-for="comment in comments"
        :key="comment.id"
        :initial-comment="comment"
        @onCommentAdded="addComment"
        @onCommentDeleted="removeComment"
      />
    </template>

    <history-comment v-else :discussion-id="discussion.reply_id" @onCommentAdded="addComment" />
  </li>
</template>
