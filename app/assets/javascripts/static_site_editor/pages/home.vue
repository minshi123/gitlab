<script>
import SkeletonLoader from '../components/skeleton_loader.vue';
import EditArea from '../components/edit_area.vue';
import SavedChangesMessage from '../components/saved_changes_message.vue';
import InvalidContentMessage from '../components/invalid_content_message.vue';
import SubmitChangesError from '../components/submit_changes_error.vue';
import appDataQuery from '../graphql/queries/app_data.query.graphql';
import sourceContentQuery from '../graphql/queries/source_content.query.graphql';
import submitContentChangesMutation from '../graphql/mutations/submit_content_changes.mutation.graphql';

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
  data() {
    return {
      content: null,
      savedContentMeta: null,
      submitChangesError: null,
      isSavingChanges: false,
    };
  },
  computed: {
    isLoadingContent() {
      return this.$apollo.queries.sourceContent.loading;
    },
    isContentLoaded() {
      return Boolean(this.sourceContent);
    },
  },
  methods: {
    onDismissError() {
      this.submitChangesError = false;
    },
    onSubmit({ content }) {
      this.content = content;
      this.submitChanges();
    },
    submitChanges() {
      this.isSavingChanges = true;

      this.$apollo
        .mutate({
          mutation: submitContentChangesMutation,
          variables: {
            project: this.appData.project,
            username: this.appData.username,
            sourcePath: this.appData.sourcePath,
            content: this.content,
          },
        })
        .then(({ data: { submitContentChanges: savedContentMeta } }) => {
          this.savedContentMeta = savedContentMeta;
        })
        .catch(e => {
          this.submitChangesError = e.message;
        })
        .finally(() => {
          this.isSavingChanges = false;
        });
    },
  },
};
</script>
<template>
  <div class="container d-flex gl-flex-direction-column pt-2 h-100">
    <!-- Success view -->
    <saved-changes-message
      v-if="savedContentMeta"
      :branch="savedContentMeta.branch"
      :commit="savedContentMeta.commit"
      :merge-request="savedContentMeta.mergeRequest"
      :return-url="appData.returnUrl"
    />

    <!-- Main view -->
    <template v-else-if="appData.isSupportedContent">
      <skeleton-loader v-if="isLoadingContent" class="w-75 gl-align-self-center gl-mt-5" />
      <submit-changes-error
        v-if="submitChangesError"
        :error="submitChangesError"
        @retry="submitChanges"
        @dismiss="onDismissError"
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
