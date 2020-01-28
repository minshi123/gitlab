<script>
import FileRow from '~/vue_shared/components/file_row.vue';
import FileRowExtra from './file_row_extra.vue';

export default {
  name: 'IdeFileRow',
  components: {
    FileRow,
    FileRowExtra,
  },
  methods: {
    toggleDropdown(val) {
      this.dropdownOpen = val;
    },
  },
  data() {
    return {
      dropdownOpen: false,
    };
  },
};
</script>

<template>
  <file-row v-bind="$attrs" v-on="$listeners">
    <file-row-extra
      v-if="$attrs.file.type === 'tree'"
      :file="$attrs.file"
      :dropdown-open="dropdownOpen"
      @toggle="toggleDropdown($event)"
    />
  </file-row>
</template>
