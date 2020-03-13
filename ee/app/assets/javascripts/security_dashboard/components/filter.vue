<script>
import { GlDropdown, GlSearchBoxByType, GlSprintf } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    GlDropdown,
    GlSearchBoxByType,
    GlSprintf,
    Icon,
  },
  props: {
    filter: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      filterTerm: '',
    };
  },
  computed: {
    filterId() {
      return this.filter.id;
    },
    selection() {
      return this.filter.selection;
    },
    selectedOptionText() {
      const { options, selection } = this.filter;
      const firstOption = options.find(filter => selection.has(filter.id)).name || '-';
      const extraOptionCount = selection.size - 1;

      return { firstOption, extraOptionCount };
    },
    filteredOptions() {
      return this.filter.options.filter(option =>
        option.name.toLowerCase().includes(this.filterTerm.toLowerCase()),
      );
    },
    qaSelector() {
      return `filter_${this.filter.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
  methods: {
    clickFilter(option) {
      this.$emit('setFilter', { filterId: this.filterId, optionId: option.id });
    },
    isSelected(option) {
      return this.selection.has(option.id);
    },
    closeDropdown() {
      this.$refs.dropdown.$children[0].hide(true);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong class="js-name">{{ filter.name }}</strong>
    <gl-dropdown ref="dropdown" class="d-block mt-1" menu-class="dropdown-extended-height">
      <template slot="button-content">
        <span class="text-truncate" :data-qa-selector="qaSelector">
          {{ selectedOptionText.firstOption }}
        </span>
        <span v-if="selectedOptionText.extraOptionCount" class="flex-grow-1 ml-1">
          <gl-sprintf :message="__('+%{extraOptionCount} more')">
            <template #extraOptionCount>{{ selectedOptionText.extraOptionCount }}</template>
          </gl-sprintf>
        </span>

        <i class="fa fa-chevron-down" aria-hidden="true"></i>
      </template>

      <div class="dropdown-title mb-0">
        {{ filter.name }}
        <button
          ref="close"
          class="btn-blank float-right"
          type="button"
          :aria-label="__('Close')"
          @click="closeDropdown"
        >
          <icon name="close" aria-hidden="true" class="vertical-align-middle" />
        </button>
      </div>

      <gl-search-box-by-type
        v-if="filter.options.length >= 20"
        ref="searchBox"
        v-model="filterTerm"
        class="m-2"
        :placeholder="__('Filter...')"
      />

      <div
        data-qa-selector="filter_dropdown_content"
        :class="{ 'dropdown-content': filterId === 'project_id' }"
      >
        <button
          v-for="option in filteredOptions"
          :key="option.id"
          role="menuitem"
          type="button"
          class="dropdown-item"
          @click="clickFilter(option)"
        >
          <span class="d-flex">
            <icon
              v-if="isSelected(option)"
              class="flex-shrink-0 js-check"
              name="mobile-issue-close"
            />
            <span :class="isSelected(option) ? 'prepend-left-4' : 'prepend-left-20'">{{
              option.name
            }}</span>
          </span>
        </button>
      </div>

      <button
        v-if="filteredOptions.length === 0"
        type="button"
        class="dropdown-item no-pointer-events text-secondary"
      >
        {{ __('No matching results') }}
      </button>
    </gl-dropdown>
  </div>
</template>

<style>
.dashboard-filter .dropdown-toggle {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}
</style>
