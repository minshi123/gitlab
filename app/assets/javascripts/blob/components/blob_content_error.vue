<script>
export default {
  props: {
    viewerError: {
      type: String,
      required: true,
    },
    blob: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
};
</script>
<template>
  <div class="file-content code">
    <div class="text-center py-4" v-html="viewerError"></div>
  </div>
</template>
