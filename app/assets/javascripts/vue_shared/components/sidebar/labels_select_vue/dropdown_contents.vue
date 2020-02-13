<script>
import { mapState } from 'vuex';

import DropdownContentsLabelsView from './dropdown_contents_labels_view.vue';
import DropdownContentsCreateView from './dropdown_contents_create_view.vue';

export default {
  components: {
    DropdownContentsLabelsView,
    DropdownContentsCreateView,
  },
  computed: {
    ...mapState(['showDropdownContentsCreateView']),
  },
};
</script>

<template>
  <div class="labels-select-dropdown-contents position-absolute">
    <dropdown-contents-labels-view v-if="!showDropdownContentsCreateView" />
    <dropdown-contents-create-view v-else />
  </div>
</template>
