<script>
import { mapState } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlLoadingIcon,
  },
  props: {
    allowLabelEdit: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    ...mapState(['labelsFetchInProgress', 'labelsSelectInProgress']),
  },
};
</script>

<template>
  <div class="title hide-collapsed append-bottom-10">
    {{ __('Labels') }}
    <template v-if="allowLabelEdit">
      <gl-loading-icon v-show="labelsFetchInProgress || labelsSelectInProgress" inline />
      <button
        type="button"
        class="edit-link btn btn-blank float-right js-sidebar-dropdown-toggle"
        data-qa-selector="labels_edit_button"
      >
        {{ __('Edit') }}
      </button>
    </template>
  </div>
</template>
