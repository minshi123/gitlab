<script>
import { GlButton, GlButtonGroup, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import {
  RICH_BLOB_VIEWER,
  RICH_BLOB_VIEWER_TITLE,
  SIMPLE_BLOB_VIEWER,
  SIMPLE_BLOB_VIEWER_TITLE,
} from './constants';
import { __ } from '~/locale';

export default {
  components: {
    GlIcon,
    GlButtonGroup,
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    blob: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      viewer: this.blob.richViewer ? RICH_BLOB_VIEWER : SIMPLE_BLOB_VIEWER,
    };
  },
  computed: {
    simpleViewer() {
      return SIMPLE_BLOB_VIEWER;
    },
    richViewer() {
      return RICH_BLOB_VIEWER;
    },
    simpleViewerTitle() {
      return __(SIMPLE_BLOB_VIEWER_TITLE);
    },
    richViewerTitle() {
      return __(RICH_BLOB_VIEWER_TITLE);
    },
    isSimpleViewer() {
      return this.viewer === SIMPLE_BLOB_VIEWER;
    },
    isRichViewer() {
      return this.viewer === RICH_BLOB_VIEWER;
    },
  },
  methods: {
    switchToViewer(viewer) {
      if (viewer !== this.viewer) {
        this.$emit('switchViewer', viewer);
      }
    },
  },
};
</script>
<template>
  <gl-button-group class="js-blob-viewer-switcher ml-2">
    <gl-button
      v-gl-tooltip.hover
      :aria-label="simpleViewerTitle"
      :title="simpleViewerTitle"
      :selected="isSimpleViewer"
      :class="isSimpleViewer ? 'active' : undefined"
      @click="switchToViewer(simpleViewer)"
    >
      <gl-icon name="code" :size="14" />
    </gl-button>
    <gl-button
      v-gl-tooltip.hover
      :aria-label="richViewerTitle"
      :title="richViewerTitle"
      :selected="isRichViewer"
      :class="isRichViewer ? 'active' : undefined"
      @click="switchToViewer(richViewer)"
    >
      <gl-icon name="document" :size="14" />
    </gl-button>
  </gl-button-group>
</template>
