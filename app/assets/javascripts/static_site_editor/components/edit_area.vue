<script>
import { GlFormTextarea } from '@gitlab/ui';

import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

import RichContentEditor from '~/vue_shared/components/rich_content_editor/rich_content_editor.vue';
import PublishToolbar from '../components/publish_toolbar.vue';
import EditHeader from '../components/edit_header.vue';

export default {
  components: {
    GlFormTextarea,
    RichContentEditor,
    PublishToolbar,
    EditHeader,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    title: {
      type: String,
      required: true,
    },
    content: {
      type: String,
      required: true,
    },
    savingChanges: {
      type: Boolean,
      required: true,
    },
    returnUrl: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      editableContent: this.content,
      saveable: false,
    };
  },
  methods: {
    onInput(newValue) {
      this.saveable = newValue !== this.content;
      this.editableContent = newValue;
    },
  },
};
</script>
<template>
  <div class="d-flex flex-grow-1 flex-column">
    <edit-header class="w-75 align-self-center py-2" :title="title" />
    <rich-content-editor
      v-if="glFeatures.richContentEditor"
      class="w-75 gl-align-self-center"
      :value="editableContent"
      @input="onInput"
    />
    <gl-form-textarea
      v-else
      class="w-75 h-100 shadow-none align-self-center"
      :value="editableContent"
      @input="onInput"
    />
    <publish-toolbar
      :return-url="returnUrl"
      :saveable="saveable"
      :saving-changes="savingChanges"
      @submit="$emit('submit', { content: editableContent })"
    />
  </div>
</template>
