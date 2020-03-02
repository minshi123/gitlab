<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { canScroll, isScrolledToTop, isScrolledToBottom } from '~/lib/utils/scroll_utils';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  data() {
    return {
      // TODO how can this be updated?
      scrollToTopEnabled: true,
      scrollToBottomEnabled: true,
    };
  },
  created() {
    window.addEventListener('scroll', this.update);
  },
  destroyed() {
    window.removeEventListener('scroll', this.update);
  },
  methods: {
    handleRefreshClick() {
      this.$emit('refresh');
    },
    handleScrollUp() {
      this.$emit('scrollUp');
    },
    handleScrollDown() {
      this.$emit('scrollDown');
    },
  },
};
</script>

<template>
  <div>
    <div
      v-gl-tooltip
      class="controllers-buttons"
      :title="__('Scroll to top')"
      aria-labelledby="scroll-to-top"
    >
      <gl-button
        id="scroll-to-top"
        class="btn-blank js-scroll-to-top"
        :aria-label="__('Scroll to top')"
        :disabled="!scrollToTopEnabled"
        @click="handleScrollUp()"
        ><icon name="scroll_up"
      /></gl-button>
    </div>
    <div
      v-gl-tooltip
      class="controllers-buttons"
      :title="__('Scroll to bottom')"
      aria-labelledby="scroll-to-bottom"
    >
      <gl-button
        id="scroll-to-bottom"
        class="btn-blank js-scroll-to-bottom"
        :aria-label="__('Scroll to bottom')"
        :disabled="!scrollToBottomEnabled"
        @click="handleScrollDown()"
        ><icon name="scroll_down"
      /></gl-button>
    </div>
    <gl-button
      id="refresh-log"
      v-gl-tooltip
      class="ml-1 px-2 js-refresh-log"
      :title="__('Refresh')"
      :aria-label="__('Refresh')"
      @click="handleRefreshClick"
    >
      <icon name="retry" />
    </gl-button>
  </div>
</template>
