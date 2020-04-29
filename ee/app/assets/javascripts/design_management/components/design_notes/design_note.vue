<script>
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import TimelineEntryItem from '~/vue_shared/components/notes/timeline_entry_item.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import DesignReplyForm from './design_reply_form.vue';
import { findNoteId } from '../../utils/design_management_utils';

export default {
  components: {
    UserAvatarLink,
    TimelineEntryItem,
    TimeAgoTooltip,
    DesignReplyForm,
  },
  props: {
    note: {
      type: Object,
      required: true,
    },
    markdownPreviewPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      noteText: this.note.body,
      isEditing: false,
    };
  },
  computed: {
    author() {
      return this.note.author;
    },
    noteAnchorId() {
      return findNoteId(this.note.id);
    },
    isNoteLinked() {
      return this.$route.hash === `#note_${this.noteAnchorId}`;
    },
  },
  mounted() {
    if (this.isNoteLinked) {
      this.$refs.anchor.$el.scrollIntoView({ behavior: 'smooth', inline: 'start' });
    }
  },
  methods: {
    hideForm() {
      this.isEditing = false;
    },
    submitForm() {
      console.log('submitted');
      this.isEditing = false;
    },
  },
};
</script>

<template>
  <timeline-entry-item :id="`note_${noteAnchorId}`" ref="anchor" class="design-note note-form">
    <user-avatar-link
      :link-href="author.webUrl"
      :img-src="author.avatarUrl"
      :img-alt="author.username"
      :img-size="40"
    />
    <a
      v-once
      :href="author.webUrl"
      class="js-user-link"
      :data-user-id="author.id"
      :data-username="author.username"
    >
      <span class="note-header-author-name bold">{{ author.name }}</span>
      <span v-if="author.status_tooltip_html" v-html="author.status_tooltip_html"></span>
      <span class="note-headline-light">@{{ author.username }}</span>
    </a>
    <span class="note-headline-light note-headline-meta">
      <span class="system-note-message"> <slot></slot> </span>
      <template v-if="note.createdAt">
        <span class="system-note-separator"></span>
        <a class="note-timestamp system-note-separator" :href="`#note_${noteAnchorId}`">
          <time-ago-tooltip :time="note.createdAt" tooltip-placement="bottom" />
        </a>
      </template>
    </span>
    <button @click="isEditing = true">Edit me</button>
    <div
      v-if="!isEditing"
      class="note-text md"
      data-qa-selector="note_content"
      v-html="note.bodyHtml"
    ></div>
    <design-reply-form
      v-else
      v-model="noteText"
      :is-saving="false"
      :button-text="__('Save comment')"
      :markdown-preview-path="markdownPreviewPath"
      @submitForm="submitForm"
      @cancelForm="hideForm"
    />
  </timeline-entry-item>
</template>
