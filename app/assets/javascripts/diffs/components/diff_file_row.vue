<script>
import FileRow from '~/vue_shared/components/file_row.vue';

export default {
  components: {
    FileRow,
  },
};
</script>

<template>
  <file-row v-bind="$attrs" v-on="$listeners" />
</template>
