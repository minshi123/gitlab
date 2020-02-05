<script>
import FileRow from '~/vue_shared/components/file_row.vue';
import FileRowStats from './file_row_stats.vue';

export default {
  name: 'DiffFileRow',
  components: {
    FileRow,
    FileRowStats,
  },
  props: {
    file: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <file-row :file="file" v-bind="$attrs" v-on="$listeners">
    <file-row-stats v-if="file.type === 'blob'" :file="file" class="mr-1" />
  </file-row>
</template>
