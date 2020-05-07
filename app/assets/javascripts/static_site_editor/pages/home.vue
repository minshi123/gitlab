<script>
import { mapState, mapActions } from 'vuex';

import SkeletonLoader from '../components/skeleton_loader.vue';
import EditArea from '../components/edit_area.vue';
import SavedChangesMessage from '../components/saved_changes_message.vue';
import InvalidContentMessage from '../components/invalid_content_message.vue';
import SubmitChangesError from '../components/submit_changes_error.vue';

import appDataQuery from '../graphql/queries/appData.query.graphql';
import sourceContentQuery from '../graphql/queries/sourceContent.query.graphql';

import createFlash from '~/flash';

import { LOAD_CONTENT_ERROR } from '../constants';

export default {
  components: {
    SkeletonLoader,
    EditArea,
    InvalidContentMessage,
    SavedChangesMessage,
    SubmitChangesError,
  },
  apollo: {
    appData: {
      query: appDataQuery,
      update: data => data,
    },
    sourceContent: {
      query: sourceContentQuery,
      update: ({
        project: {
          file: { title, content },
        },
      }) => {
        return { title, content };
      },
      error() {
        this.onLoadingError();
      },
      variables() {
        return {
          project: this.appData.project,
          sourcePath: this.appData.sourcePath,
        };
      },
      skip() {
        return !this.appData.isSupportedContent;
      },
      error() {
        createFlash(LOAD_CONTENT_ERROR);
      },
    },
  },
  computed: {
    ...mapState(['isSavingChanges', 'submitChangesError', 'savedContentMeta']),
    isLoadingContent() {
      return this.$apollo.queries.sourceContent.loading;
    },
    isContentLoaded() {
      return Boolean(this.sourceContent);
    },
  },
  methods: {
    ...mapActions(['setContent', 'submitChanges', 'dismissSubmitChangesError']),
    onSubmit({ content }) {
      this.setContent(content);
      this.submitChanges();
    },
  },
};
</script>
<template>
  <div class="d-flex justify-content-center h-100 pt-2">
    <!-- Success view -->
    <saved-changes-message
      v-if="savedContentMeta"
      class="w-75"
      :branch="savedContentMeta.branch"
      :commit="savedContentMeta.commit"
      :merge-request="savedContentMeta.mergeRequest"
      :return-url="appData.returnUrl"
    />

    <!-- Main view -->
    <template v-else-if="appData.isSupportedContent">
      <skeleton-loader v-if="isLoadingContent" class="w-50 gl-align-self-start gl-mt-5" />
      <submit-changes-error
        v-if="submitChangesError"
        class="w-75 align-self-center"
        :error="submitChangesError"
        @retry="submitChanges"
        @dismiss="dismissSubmitChangesError"
      />
      <edit-area
        v-if="isContentLoaded"
        :title="sourceContent.title"
        :content="sourceContent.content"
        :saving-changes="isSavingChanges"
        :return-url="appData.returnUrl"
        @submit="onSubmit"
      />
    </template>

    <!-- Error view -->
    <invalid-content-message v-else class="w-75" />
  </div>
</template>
