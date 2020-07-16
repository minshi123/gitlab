<script>
import { mapState } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';
import { isInIssuePage } from '~/lib/utils/common_utils';

export default {
  components: {
    Icon,
  },
  computed: {
    isIssuePage() {
      return isInIssuePage();
    },
    ...mapState({
      noteableData(data) {
        return this.isIssuePage ? data.noteableData : data.notes.noteableData;
      },
    }),
    confidential() {
      return this.noteableData.confidential;
    },
    dicussionLocked() {
      return this.noteableData.discussion_locked;
    },
  },
};
</script>

<template>
  <div class="gl-display-inline-block">
    <div v-if="confidential" class="issuable-warning-icon inline">
      <icon class="icon" name="eye-slash" data-testid="confidential" />
    </div>

    <div v-if="dicussionLocked" class="issuable-warning-icon inline">
      <icon class="icon" name="lock" data-testid="locked" />
    </div>
  </div>
</template>
