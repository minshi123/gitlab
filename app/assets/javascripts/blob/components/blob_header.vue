<script>
import ViewerSwitcher from './blob_header_viewer_switcher.vue';
import DefaultActions from './blob_header_default_actions.vue';
import BlobFilepath from './blob_header_filepath.vue';

export default {
  components: {
    ViewerSwitcher,
    DefaultActions,
    BlobFilepath,
  },
  props: {
    blob: {
      type: Object,
      required: true,
    },
    hideDefaultActions: {
      type: Boolean,
      default: false,
    },
    hideViewerSwitcher: {
      type: Boolean,
      default: false,
    },
  },
  computed: {
    showViewerSwitcher() {
      return !this.hideViewerSwitcher && Boolean(this.blob.simpleViewer && this.blob.richViewer);
    },
    showDefaultActions() {
      return !this.hideDefaultActions;
    },
  },
};
</script>
<template>
  <div class="js-file-title file-title-flex-parent">
    <blob-filepath :blob="blob">
      <template #filepathPrepend>
        <slot name="prepend"></slot>
      </template>
    </blob-filepath>

    <div class="file-actions d-none d-sm-block">
      <viewer-switcher v-if="showViewerSwitcher" :blob="blob" />

      <slot name="actions"></slot>

      <default-actions v-if="showDefaultActions" :blob="blob" />
    </div>
  </div>
</template>
