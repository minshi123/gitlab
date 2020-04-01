import GetSnippetQuery from './queries/snippet.query.graphql';
import GetSnippetBlobQuery from './queries/snippet.blob.query.graphql';

export const getSnippetMixin = {
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
  },
  props: {
    snippetGid: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      snippet: {},
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.snippet.loading;
    },
  },
};

export const getSnippetBlob = {
  apollo: {
    blob: {
      query: GetSnippetBlobQuery,
      variables() {
        return {
          ids: this.snippet.id,
        };
      },
      update: data => data.snippets.edges[0].node.blob,
      result(res) {
        debugger;
        if (this.onSnippetBlob) {
          this.onSnippetBlob(res.data.snippets.edges[0].node.blob);
        }
      },
    },
  },
  data() {
    return {
      blob: {},
    };
  },
  computed: {
    isBlobLoading() {
      return this.$apollo.queries.blob.loading;
    },
  },
};
