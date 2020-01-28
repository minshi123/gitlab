<script>
import FileRow from '~/vue_shared/components/file_row.vue';
import FileRowExtra from './file_row_extra.vue';

export default {
  name: 'IdeFileRow',
  components: {
    FileRow,
    FileRowExtra,
  },
  props: {
    file: {
      type: Object,
      required: true,
    },
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
  <file-row :file="file" @mouseleave="toggleDropdown(false)" v-bind="$attrs" v-on="$listeners">
    <file-row-extra
      v-if="file.type === 'tree'"
      :file="file"
      :dropdown-open="dropdownOpen"
      @toggle="toggleDropdown($event)"
    />
  </file-row>
</template>
