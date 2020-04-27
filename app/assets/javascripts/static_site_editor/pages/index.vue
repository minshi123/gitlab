<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import { GlSkeletonLoader } from '@gitlab/ui';

import { SUCCESS_ROUTE_NAME } from '../router/constants';

import EditArea from '../components/edit_area.vue';
import EditHeader from '../components/edit_header.vue';
import PublishToolbar from '../components/publish_toolbar.vue';
import InvalidContentMessage from '../components/invalid_content_message.vue';
import SubmitChangesError from '../components/submit_changes_error.vue';

export default {
  components: {
    EditArea,
    EditHeader,
    InvalidContentMessage,
    GlSkeletonLoader,
    PublishToolbar,
    SubmitChangesError,
  },
  computed: {
    ...mapState([
      'content',
      'isLoadingContent',
      'isSavingChanges',
      'isContentLoaded',
      'isSupportedContent',
      'returnUrl',
      'title',
      'submitChangesError',
    ]),
    ...mapGetters(['contentChanged']),
  },
  mounted() {
    if (this.isSupportedContent) {
      this.loadContent();
    }
  },
  methods: {
    ...mapActions(['loadContent', 'setContent', 'submitChanges', 'dismissSubmitChangesError']),
    submit() {
      return this.submitChanges().then(() => this.$router.push({ name: SUCCESS_ROUTE_NAME }));
    },
  },
};
</script>
<template>
  <div class="d-flex justify-content-center h-100 pt-2">
    <!-- Main view -->
    <template v-if="isSupportedContent">
      <div v-if="isLoadingContent" class="w-50 h-50">
        <gl-skeleton-loader :width="500" :height="102">
          <rect width="500" height="16" rx="4" />
          <rect y="20" width="375" height="16" rx="4" />
          <rect x="380" y="20" width="120" height="16" rx="4" />
          <rect y="40" width="250" height="16" rx="4" />
          <rect x="255" y="40" width="150" height="16" rx="4" />
          <rect x="410" y="40" width="90" height="16" rx="4" />
        </gl-skeleton-loader>
      </div>
      <div v-if="isContentLoaded" class="d-flex flex-grow-1 flex-column">
        <submit-changes-error
          v-if="submitChangesError"
          class="w-75 align-self-center"
          :error="submitChangesError"
          @retry="submitChanges"
          @dismiss="dismissSubmitChangesError"
        />
        <edit-header class="w-75 align-self-center py-2" :title="title" />
        <edit-area
          class="w-75 h-100 shadow-none align-self-center"
          :value="content"
          @input="setContent"
        />
        <publish-toolbar
          :return-url="returnUrl"
          :saveable="contentChanged"
          :saving-changes="isSavingChanges"
          @submit="submit"
        />
      </div>
    </template>

    <!-- Error view -->
    <invalid-content-message v-else class="w-75" />
  </div>
</template>
