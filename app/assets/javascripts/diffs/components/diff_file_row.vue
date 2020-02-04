<script>
import FileRow from '~/vue_shared/components/file_row.vue';
import ChangedFileIcon from '~/vue_shared/components/changed_file_icon.vue';

export default {
  components: {
    FileRow,
    ChangedFileIcon,
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
    <changed-file-icon :file="file" :size="16" class="append-right-5" />
  </file-row>
</template>
