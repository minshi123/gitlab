<script>
import { __ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
  },
  props: {
    selectedEpic: {
      type: Object,
      required: false,
      default: null,
    },
    toggleTextClass: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    buttonText() {
      return this.selectedEpic?.id ? this.selectedEpic.title : __('Epic');
    },
  },
};
</script>

<template>
  <button
    type="button"
    class="dropdown-menu-toggle js-epic-select js-extra-options"
    data-display="static"
    data-toggle="dropdown"
  >
    <span class="dropdown-toggle-text" :class="toggleTextClass">{{ buttonText }}</span>
    <icon name="chevron-down" />
  </button>
</template>
