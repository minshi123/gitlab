<script>
import { mapState } from 'vuex';
import {
  GlFormGroup,
  GlSegmentedControl,
  GlNewDropdown as GlDropdown,
  GlNewDropdownItem as GlDropdownItem,
  GlNewDropdownDivider as GlDropdownDivider,
} from '@gitlab/ui';

import { __ } from '~/locale';
import Api from '~/api';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';

export default {
  components: {
    GlFormGroup,
    GlSegmentedControl,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    FilteredSearchBar,
  },
  data() {
    return {
      selectedPreset: this.presetType,
      availablePresets: [
        { text: __('Quarters'), value: 'QUARTERS' },
        { text: __('Months'), value: 'MONTHS' },
        { text: __('Weeks'), value: 'WEEKS' },
      ],
    };
  },
  computed: {
    ...mapState(['presetType', 'epicsState', 'sortedBy', 'fullPath', 'labelsPath']),
    selectedEpicStateTitle() {
      if (this.epicsState === 'all') {
        return __('All epics');
      } else if (this.epicsState === 'opened') {
        return __('Open epics');
      }
      return __('Closed epics');
    },
  },
  methods: {
    getFilteredSearchTokens() {
      return [
        {
          type: 'author_username',
          icon: 'user',
          title: __('Author'),
          unique: false,
          symbol: '@',
          token: AuthorToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchAuthors: Api.users.bind(Api),
        },
      ];
    },
    getFilteredSearchSortOptions() {
      return [
        {
          id: 1,
          selected: this.sortedBy.includes('start_date'),
          title: __('Start date'),
          sortDirection: {
            descending: 'start_date_desc',
            ascending: 'start_date_asc',
          },
        },
        {
          id: 2,
          selected: this.sortedBy.includes('end_date'),
          title: __('Due date'),
          sortDirection: {
            descending: 'end_date_desc',
            ascending: 'end_date_asc',
          },
        },
      ];
    },
    handleEpicStateChange(epicsState) {
      debugger;
    },
    handleFilterEpics(filters) {
      debugger;
    },
    handleSortEpics(sortBy) {
      debugger;
    },
  },
};
</script>

<template>
  <div class="epics-filters epics-roadmap-filters">
    <div
      class="epics-details-filters filtered-search-block d-flex flex-column flex-md-row row-content-block second-block"
    >
      <gl-form-group class="mb-0">
        <gl-segmented-control v-model="presetType" :options="availablePresets" buttons />
      </gl-form-group>
      <gl-dropdown :text="selectedEpicStateTitle" class="mx-2">
        <gl-dropdown-item
          :is-check-item="true"
          :is-checked="epicsState === 'all'"
          @click="handleEpicStateChange('all')"
          >{{ __('All epics') }}</gl-dropdown-item
        >
        <gl-dropdown-divider />
        <gl-dropdown-item
          :is-check-item="true"
          :is-checked="epicsState === 'opened'"
          @click="handleEpicStateChange('opened')"
          >{{ __('Open epics') }}</gl-dropdown-item
        >
        <gl-dropdown-item
          :is-check-item="true"
          :is-checked="epicsState === 'closed'"
          @click="handleEpicStateChange('closed')"
          >{{ __('Closed epics') }}</gl-dropdown-item
        >
      </gl-dropdown>
      <filtered-search-bar
        :namespace="fullPath"
        :search-input-placeholder="__('Search or filter results...')"
        :tokens="getFilteredSearchTokens()"
        :sort-options="getFilteredSearchSortOptions()"
        :initial-filter-value="[]"
        :initial-sort-by="sortedBy"
        recent-searches-storage-key="epics"
        class="flex-grow-1"
        @onFilter="handleFilterEpics"
        @onSort="handleSortEpics"
      />
    </div>
  </div>
</template>
