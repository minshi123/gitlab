<script>
import Icon from '~/vue_shared/components/icon.vue';
import { n__ } from '~/locale';

export default {
  components: { Icon },
  props: {
    addedLines: {
      type: Number,
      required: true,
    },
    removedLines: {
      type: Number,
      required: true,
    },
    diffFilesLength: {
      type: Number,
      required: false,
      default: null,
    },
  },
  computed: {
    filesText() {
      return n__('file', 'files', this.diffFilesLength);
    },
    isCompareVersionsHeader() {
      return Boolean(this.diffFilesLength);
    },
  },
};
</script>

<template>
  <div
    class="diff-stats"
    :class="{
      'is-compare-versions-header d-none d-lg-inline-flex': isCompareVersionsHeader,
      'd-inline-flex': !isCompareVersionsHeader,
    }"
  >
    <div v-if="diffFilesLength !== null" class="diff-stats-group">
      <strong class="text-secondary">{{ diffFilesLength }} {{ filesText }}</strong>
    </div>
    <div
      class="diff-stats-group cgreen d-flex align-items-center"
      :class="[isCompareVersionsHeader ? 'font-weight-bold' : null]"
    >
      <icon name="plus" class="diff-stats-icon" :size="12" />
      <!-- <span>+</span> -->
      <span>{{ addedLines }}</span>
    </div>
    <div
      class="diff-stats-group cred d-flex align-items-center"
      :class="[isCompareVersionsHeader ? 'font-weight-bold' : null]"
    >
      <!-- SAM: change this to the minus icon when added -->
      <icon name="file-deletion" class="diff-stats-icon" :size="12" />
      <!-- <span>-</span> -->
      <span>{{ removedLines }}</span>
    </div>
  </div>
</template>
