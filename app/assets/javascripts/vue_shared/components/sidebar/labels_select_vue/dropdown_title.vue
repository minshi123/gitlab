<script>
import { mapState, mapActions } from 'vuex';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlLoadingIcon,
  },
  props: {
    allowLabelEdit: {
      type: Boolean,
      required: true,
    },
    labelsSelectInProgress: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    ...mapState(['labelsFetchInProgress']),
  },
  methods: {
    ...mapActions(['toggleDropdownButtonAndContents']),
  },
};
</script>

<template>
  <div class="title hide-collapsed append-bottom-10">
    {{ __('Labels') }}
    <template v-if="allowLabelEdit">
      <gl-loading-icon v-show="labelsSelectInProgress" inline />
      <gl-button
        variant="link"
        class="pull-right js-sidebar-dropdown-toggle"
        data-qa-selector="labels_edit_button"
        @click="toggleDropdownButtonAndContents"
        >{{ __('Edit') }}</gl-button
      >
    </template>
  </div>
</template>
