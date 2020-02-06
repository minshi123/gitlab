<script>
import { mapActions } from 'vuex';

import createStore from './store';

import DropdownTitle from './dropdown_title.vue';
import DropdownValue from './dropdown_value.vue';

export default {
  store: createStore(),
  components: {
    DropdownTitle,
    DropdownValue,
  },
  props: {
    allowLabelEdit: {
      type: Boolean,
      required: true,
    },
    allowLabelCreate: {
      type: Boolean,
      required: true,
    },
    dropdownOnly: {
      type: Boolean,
      required: false,
      default: false,
    },
    labels: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  mounted() {
    this.setInitialState({
      allowLabelEdit: this.allowLabelEdit,
      allowLabelCreate: this.allowLabelCreate,
      labels: this.labels,
    });
  },
  methods: {
    ...mapActions(['setInitialState']),
  },
};
</script>

<template>
  <div class="labels-select-wrapper">
    <div v-if="!dropdownOnly" class="block labels js-labels-block">
      <dropdown-title :allow-label-edit="allowLabelEdit" />
      <dropdown-value>
        <slot></slot>
      </dropdown-value>
    </div>
  </div>
</template>
