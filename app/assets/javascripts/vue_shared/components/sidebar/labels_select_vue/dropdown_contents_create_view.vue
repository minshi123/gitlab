<script>
import { mapState, mapActions } from 'vuex';
import {
  GlTooltipDirective,
  GlButton,
  GlIcon,
  GlFormInput,
  GlLink,
  GlLoadingIcon,
} from '@gitlab/ui';

import { s__ } from '~/locale';

const suggestedColors = [
  { '#0033CC': s__('SuggestedColors|UA blue') },
  { '#428BCA': s__('SuggestedColors|Moderate blue') },
  { '#44AD8E': s__('SuggestedColors|Lime green') },
  { '#A8D695': s__('SuggestedColors|Feijoa') },
  { '#5CB85C': s__('SuggestedColors|Slightly desaturated green') },
  { '#69D100': s__('SuggestedColors|Bright green') },
  { '#004E00': s__('SuggestedColors|Very dark lime green') },
  { '#34495E': s__('SuggestedColors|Very dark desaturated blue') },
  { '#7F8C8D': s__('SuggestedColors|Dark grayish cyan') },
  { '#A295D6': s__('SuggestedColors|Slightly desaturated blue') },
  { '#5843AD': s__('SuggestedColors|Dark moderate blue') },
  { '#8E44AD': s__('SuggestedColors|Dark moderate violet') },
  { '#FFECDB': s__('SuggestedColors|Very pale orange') },
  { '#AD4363': s__('SuggestedColors|Dark moderate pink') },
  { '#D10069': s__('SuggestedColors|Strong pink') },
  { '#CC0033': s__('SuggestedColors|Strong red') },
  { '#FF0000': s__('SuggestedColors|Pure red') },
  { '#D9534F': s__('SuggestedColors|Soft red') },
  { '#D1D100': s__('SuggestedColors|Strong yellow') },
  { '#F0AD4E': s__('SuggestedColors|Soft orange') },
  { '#AD8D43': s__('SuggestedColors|Dark moderate orange') },
];

export default {
  suggestedColors,
  components: {
    GlButton,
    GlIcon,
    GlFormInput,
    GlLink,
    GlLoadingIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  data() {
    return {
      labelTitle: '',
      selectedColor: '',
    };
  },
  computed: {
    ...mapState(['labelsCreateTitle', 'labelCreateInProgress']),
    disableCreate() {
      return !this.labelTitle.length || !this.selectedColor.length || this.labelCreateInProgress;
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.$refs.titleInput.$el.focus();
    });
  },
  methods: {
    ...mapActions([
      'toggleDropdownButtonAndContents',
      'toggleDropdownContentsCreateView',
      'createLabel',
    ]),
    getColorCode(color) {
      return Object.keys(color).pop();
    },
    getColorName(color) {
      return Object.values(color).pop();
    },
    handleColorClick(color) {
      this.selectedColor = this.getColorCode(color);
    },
    handleCreateClick() {
      this.createLabel({
        title: this.labelTitle,
        color: this.selectedColor,
      });
    },
  },
};
</script>

<template>
  <div class="labels-select-contents-create">
    <div class="dropdown-title d-flex align-items-center pt-0 pb-2">
      <gl-button
        :aria-label="__('Go back')"
        variant="link"
        size="sm"
        class="dropdown-header-button p-0"
        @click="toggleDropdownContentsCreateView"
      >
        <gl-icon name="arrow-left" />
      </gl-button>
      <span class="flex-grow-1">{{ labelsCreateTitle }}</span>
      <gl-button
        :aria-label="__('Close')"
        variant="link"
        size="sm"
        class="dropdown-header-button p-0"
        @click="toggleDropdownButtonAndContents"
      >
        <gl-icon name="close" />
      </gl-button>
    </div>
    <div class="dropdown-input">
      <gl-form-input
        ref="titleInput"
        v-model.trim="labelTitle"
        :placeholder="__('Name new label')"
      />
    </div>
    <div class="dropdown-content pl-2 pr-2">
      <div class="suggest-colors suggest-colors-dropdown mt-0 mb-2">
        <gl-link
          v-for="(color, index) in $options.suggestedColors"
          :key="index"
          v-gl-tooltip:tooltipcontainer
          :style="{ backgroundColor: getColorCode(color) }"
          :title="getColorName(color)"
          @click.prevent="handleColorClick(color)"
        />
      </div>
      <div class="color-input-container d-flex">
        <span
          class="dropdown-label-color-preview position-relative position-relative d-inline-block"
          :style="{ backgroundColor: selectedColor }"
        ></span>
        <gl-form-input v-model.trim="selectedColor" :placeholder="__('Use custom color #FF0000')" />
      </div>
    </div>
    <div class="clearfix pl-2 pt-2 pr-2">
      <gl-button
        :disabled="disableCreate"
        variant="primary"
        class="pull-left d-flex align-items-center"
        @click="handleCreateClick"
      >
        <gl-loading-icon v-show="labelCreateInProgress" :inline="true" class="mr-1" />
        {{ __('Create') }}
      </gl-button>
      <gl-button class="pull-right">{{ __('Cancel') }}</gl-button>
    </div>
  </div>
</template>
