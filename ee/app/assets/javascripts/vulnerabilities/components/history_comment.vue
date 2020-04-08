<script>
import { GlDeprecatedButton, GlNewButton, GlFormTextarea, GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import EventItem from 'ee/vue_shared/security_reports/components/event_item.vue';
import { __, s__ } from '~/locale';
import axios from '~/lib/utils/axios_utils';

export default {
  components: {
    GlDeprecatedButton,
    GlNewButton,
    EventItem,
    GlFormTextarea,
    GlLoadingIcon,
  },

  props: {
    initialComment: {
      type: Object,
      required: false,
      default: undefined,
    },
    discussionId: {
      type: String,
      required: false,
      default: undefined,
    },
  },

  data() {
    return {
      comment: this.initialComment,
      isEditingComment: false,
      isSavingComment: false,
      isDeletingComment: false,
      isConfirmingDeletion: false,
      commentText: this.initialComment?.note,
    };
  },

  computed: {
    actionButtons() {
      return [
        {
          iconName: 'pencil',
          callback: this.showCommentTextArea,
          title: __('Edit Comment'),
        },
        {
          iconName: 'remove',
          callback: this.showDeleteConfirmation,
          title: __('Delete Comment'),
        },
      ];
    },
  },

  methods: {
    showCommentTextArea() {
      this.isEditingComment = true;
    },
    saveComment() {
      this.isSavingComment = true;
      const hasComment = Boolean(this.comment);
      const axiosData = { note: { note: this.commentText } };

      if (!hasComment) {
        axiosData.in_reply_to_discussion_id = this.discussionId;
      }

      axios({
        method: hasComment ? 'put' : 'post',
        data: axiosData,
        url: hasComment
          ? `${window.location.href}/notes/${this.comment.id}`
          : `${window.location.href}/notes`,
      })
        .then(({ data }) => {
          if (hasComment) {
            Object.assign(this.comment, data);
          } else {
            this.comment = data;
            this.$emit('onCommentAdded', data);
          }

          this.isEditingComment = false;
        })
        .catch(() => {
          createFlash(
            s__(
              'VulnerabilityManagement|Something went wrong while trying to save the comment. Please try again later.',
            ),
          );
        })
        .finally(() => {
          this.isSavingComment = false;
        });
    },
    deleteComment() {
      this.isDeletingComment = true;

      axios
        .delete(`${window.location.href}/notes/${this.comment.id}`)
        .then(() => {
          this.$emit('onCommentDeleted', this.comment);
        })
        .catch(() => {
          createFlash(
            s__(
              'VulnerabilityManagement|Something went wrong while trying to delete the comment. Please try again later.',
            ),
          );
        })
        .finally(() => {
          this.isDeletingComment = false;
        });
    },
    cancelEditingComment() {
      this.commentText = this.comment?.note; // Reset the comment back to the original text.
      this.isEditingComment = false;
    },
    showDeleteConfirmation() {
      this.isConfirmingDeletion = true;
    },
    cancelDeleteConfirmation() {
      this.isConfirmingDeletion = false;
    },
  },
};
</script>

<template>
  <div v-if="isEditingComment" class="discussion-reply-holder">
    <gl-form-textarea
      v-model="commentText"
      :placeholder="s__('vulnerability|Add a comment')"
      :disabled="isSavingComment"
      autofocus
    />
    <div class="mt-3">
      <gl-new-button variant="success" :disabled="isSavingComment" @click="saveComment">
        <gl-loading-icon v-if="isSavingComment" class="mr-1" />
        {{ __('Save comment') }}
      </gl-new-button>
      <gl-new-button class="ml-1" :disabled="isSavingComment" @click="cancelEditingComment">
        {{ __('Cancel') }}
      </gl-new-button>
    </div>
  </div>

  <event-item
    v-else-if="comment"
    :author="comment.author"
    :created-at="comment.created_at"
    :show-action-buttons="comment.current_user.can_edit"
    :show-right-slot="isConfirmingDeletion"
    :action-buttons="actionButtons"
    icon-name="comment"
    icon-class="timeline-icon mr-0"
    class="mx-3 my-4"
  >
    <div v-html="comment.note"></div>

    <template #right-content>
      <gl-new-button variant="danger" :disabled="isDeletingComment" @click="deleteComment">
        <gl-loading-icon v-if="isDeletingComment" class="mr-1" />
        {{ __('Delete') }}
      </gl-new-button>
      <gl-new-button class="ml-2" :disabled="isDeletingComment" @click="cancelDeleteConfirmation">
        {{ __('Cancel') }}
      </gl-new-button>
    </template>
  </event-item>

  <div v-else class="discussion-reply-holder">
    <gl-deprecated-button class="btn-text-field" @click="showCommentTextArea">
      {{ s__('vulnerability|Add a comment') }}
    </gl-deprecated-button>
  </div>
</template>
