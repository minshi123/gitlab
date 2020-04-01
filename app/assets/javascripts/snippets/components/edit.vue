<script>
import Flash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import SnippetDescriptionEdit from './snippet_description_edit.vue';
import SnippetVisibilityEdit from './snippet_visibility_edit.vue';
import SnippetBlobEdit from './snippet_blob_edit.vue';
import TitleField from '~/vue_shared/components/form/title.vue';
import UpdateSnippetMutation from '../mutations/updateSnippet.mutation.graphql';
import CreateSnippetMutation from '../mutations/createSnippet.mutation.graphql';

import { __, sprintf } from '~/locale';
import { getBaseURL, joinPaths } from '~/lib/utils/url_utility';

import { GlButton, GlLoadingIcon } from '@gitlab/ui';

import GetSnippetBlobQuery from '../queries/snippet.blob.query.graphql';
import GetSnippetQuery from '../queries/snippet.query.graphql';

export default {
  components: {
    SnippetDescriptionEdit,
    SnippetVisibilityEdit,
    SnippetBlobEdit,
    TitleField,
    GlButton,
    GlLoadingIcon,
  },
  apollo: {
    snippet: {
      query: GetSnippetQuery,
      variables() {
        return {
          ids: this.snippetGid,
        };
      },
      update: data => data.snippets.edges[0].node,
    },
    blob: {
      query: GetSnippetBlobQuery,
      variables() {
        return {
          ids: this.snippet.id,
        };
      },
      update: data => data.snippets.edges[0].node.blob,
      result(res) {
        if (this.onSnippetBlob) {
          this.onSnippetBlob(res.data.snippets.edges[0].node.blob);
        }
      },
    },
  },
  props: {
    markdownPreviewPath: {
      type: String,
      required: true,
    },
    markdownDocsPath: {
      type: String,
      required: true,
    },
    visibilityHelpLink: {
      type: String,
      default: '',
      required: false,
    },
    projectPath: {
      type: String,
      default: '',
      required: false,
    },
    snippetGid: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      blob: {},
      fileName: '',
      snippet: {},
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.snippet.loading;
    },
    isBlobLoading() {
      return this.$apollo.queries.blob.loading;
    },
    isProjectSnippet() {
      return Boolean(this.projectPath);
    },
    apiData() {
      return {
        id: this.snippet.id,
        title: this.snippet.title,
        description: this.snippet.description,
        visibilityLevel: this.snippet.visibilityLevel,
        fileName: this.filename,
        content: this.content,
      };
    },
  },
  methods: {
    updateFileName(newName) {
      this.fileName = newName;
    },
    onSnippetBlob(blob) {
      this.fileName = blob.name;
      const baseUrl = getBaseURL();
      const url = joinPaths(baseUrl, blob.rawPath);
      axios
        .get(url)
        .then(res => {
          this.content = res.data;
        })
        .catch(e => {
          this.flashAPIFailure(e);
        });
    },
    flashAPIFailure(err) {
      Flash(sprintf(__("Can't update snippet: %{err}"), { err }));
    },
    updateSnippet() {
      this.$apollo
        .mutate({
          mutation: UpdateSnippetMutation,
          variables: {
            input: {
              ...this.apiData,
            },
          },
        })
        .then(({ data }) => {
          if (data?.updateSnippet?.errors.length) {
            this.flashAPIFailure(data.updateSnippet.errors[0]);
          }
        })
        .catch(err => this.flashAPIFailure(err));
    },
    createSnippet() {
      this.$apollo
        .mutate({
          mutation: CreateSnippetMutation,
          variables: {
            input: {
              ...this.apiData,
              projectPath: this.projectPath,
            },
          },
        })
        .then(({ data }) => {
          if (data?.updateSnippet?.errors.length) {
            this.flashAPIFailure(data.updateSnippet.errors[0]);
          }
        })
        .catch(err => this.flashAPIFailure(err));
    },
  },
};
</script>
<template>
  <form
    class="snippet-form js-requires-input js-quick-submit common-note-form"
    :data-snippet-type="isProjectSnippet ? 'project' : 'personal'"
  >
    <gl-loading-icon
      v-if="isLoading"
      :label="__('Loading snippet')"
      :size="2"
      class="loading-animation prepend-top-20 append-bottom-20"
    />
    <template v-else>
      <title-field v-model="snippet.title" required :autofocus="false" />
      <snippet-description-edit
        v-model="snippet.description"
        :markdown-preview-path="markdownPreviewPath"
        :markdown-docs-path="markdownDocsPath"
      />
      <!--      <snippet-blob-edit v-model="content" :file-name="fileName" @name-change="updateFileName" />-->
      <snippet-visibility-edit
        v-model="snippet.visibilityLevel"
        :help-link="visibilityHelpLink"
        :is-project-snippet="isProjectSnippet"
      />
      <gl-button @click="updateSnippet">Submit</gl-button>
    </template>
  </form>
</template>
