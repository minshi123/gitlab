<script>
import BlobHeaderEdit from '~/blob/components/blob_edit_header.vue';
import BlobContentEdit from '~/blob/components/blob_edit_content.vue';

export default {
  components: {
    BlobHeaderEdit,
    BlobContentEdit,
  },
  props: {
    fileName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      name: this.fileName,
    };
  },
  methods: {
    emitFileNameChange(newFileName) {
      this.$emit('name-change', newFileName);
    },
  },
};
</script>
<template>
  <div class="form-group file-editor">
    <label>{{ s__('Snippets|File') }}</label>
    <div class="file-holder snippet">
      <blob-header-edit v-model="name" @input="emitFileNameChange" />
      <blob-content-edit v-bind="$attrs" :file-name="name" v-on="$listeners" />
    </div>
  </div>
</template>
