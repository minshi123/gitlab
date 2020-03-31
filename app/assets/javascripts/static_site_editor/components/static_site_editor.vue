<script>
import { mapState } from 'vuex';
import EditArea from './edit_area.vue';

export default {
  components: {
    EditArea
  },
  computed: {
    ...mapState(['content', 'isContentLoaded']),
  }
}
</script>
<template>
  <div class="static-site-editor">
    <edit-area v-if="isContentLoaded" :value="content" />
  </div>
</template>
