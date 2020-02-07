<script>
import _ from 'underscore';
import tooltip from '../directives/tooltip';

export default {
  directives: {
    tooltip,
  },
  props: {
    title: {
      type: String,
      required: false,
      default: '',
    },
    placement: {
      type: String,
      required: false,
      default: 'top',
    },
    truncateTarget: {
      type: [String, Function],
      required: false,
      default: '',
    },
  },
  data() {
    return {
      showTooltip: false,
    };
  },
  watch: {
    title() {
      this.$nextTick(this.updateTooltip);
    },
  },
  mounted() {
    this.updateTooltip();
  },
  methods: {
    selectTarget() {
      if (_.isFunction(this.truncateTarget)) {
        return this.truncateTarget(this.$el);
      } else if (this.truncateTarget === 'child') {
        return this.$el.childNodes[0];
      }

      return this.$el;
    },
    updateTooltip() {
      const target = this.selectTarget();
      this.showTooltip = Boolean(target && target.scrollWidth > target.offsetWidth);
    },
  },
};
</script>

<template>
  <span
    v-if="showTooltip"
    v-tooltip
    :title="title"
    :data-placement="placement"
    class="js-show-tooltip"
  >
    <slot></slot>
  </span>
  <span v-else> <slot></slot> </span>
</template>
