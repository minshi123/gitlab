<script>
import { mapState } from 'vuex';

import { __ } from '~/locale';
import { isScopedLabel } from '~/lib/utils/common_utils';
import DropdownValueRegularLabel from '~/vue_shared/components/sidebar/labels_select/dropdown_value_regular_label.vue';
import DropdownValueScopedLabel from '~/vue_shared/components/sidebar/labels_select/dropdown_value_scoped_label.vue';

export default {
  components: {
    DropdownValueRegularLabel,
    DropdownValueScopedLabel,
  },
  computed: {
    ...mapState([
      'selectedLabels',
      'allowScopedLabels',
      'labelFilterBasePath',
      'scopedLabelsDocumentationPath',
    ]),
  },
  methods: {
    labelFilterUrl(label) {
      return `${this.labelFilterBasePath}?label_name[]=${encodeURIComponent(label.title)}`;
    },
    labelStyle(label) {
      return {
        color: label.textColor,
        backgroundColor: label.color,
      };
    },
    scopedLabelsDescription({ description = '' }) {
      return `<span class="font-weight-bold scoped-label-tooltip-title">${__(
        'Scoped label',
      )}</span><br />${description}`;
    },
    showScopedLabels(label) {
      return this.allowScopedLabels && isScopedLabel(label);
    },
  },
};
</script>

<template>
  <div
    :class="{
      'has-labels': selectedLabels.length,
    }"
    class="hide-collapsed value issuable-show-labels js-value"
  >
    <span v-if="!selectedLabels.length" class="text-secondary">
      <slot>{{ __('None') }}</slot>
    </span>
    <template v-for="label in selectedLabels" v-else>
      <dropdown-value-scoped-label
        v-if="showScopedLabels(label)"
        :key="label.id"
        :label="label"
        :label-filter-url="labelFilterUrl(label)"
        :label-style="labelStyle(label)"
        :scoped-labels-documentation-link="scopedLabelsDocumentationPath"
      />
      <dropdown-value-regular-label
        v-else
        :key="label.id"
        :label="label"
        :label-filter-url="labelFilterUrl(label)"
        :label-style="labelStyle(label)"
      />
    </template>
  </div>
</template>
