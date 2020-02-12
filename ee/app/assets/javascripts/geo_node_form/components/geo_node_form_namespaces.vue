<script>
import { GlIcon, GlSearchBoxByType, GlDropdown, GlButton } from '@gitlab/ui';
import { debounce } from 'underscore';
import Api from '~/api';
import createFlash from '~/flash';
import { __, sprintf } from '~/locale';

export default {
  name: 'GeoNodeFormNamespaces',
  components: {
    GlIcon,
    GlSearchBoxByType,
    GlDropdown,
    GlButton,
  },
  props: {
    selectedNamespaces: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      namespaceSearch: '',
      synchronizationNamespaces: [],
    };
  },
  computed: {
    dropdownTitle() {
      if (this.selectedNamespaces.length === 0) {
        return __('Select groups to replicate');
      }
      return sprintf(__('Groups selected: %{count}'), { count: this.selectedNamespaces.length });
    },
    noSyncNamespaces() {
      return this.synchronizationNamespaces.length === 0;
    },
  },
  watch: {
    namespaceSearch: debounce(function debounceSearch() {
      this.searchNamespaces(this.namespaceSearch);
    }, 500),
  },
  methods: {
    searchNamespaces(search) {
      Api.groups(search)
        .then(res => {
          this.synchronizationNamespaces = res;
        })
        .catch(() => {
          createFlash(__("There was an error fetching the Node's Groups"));
        });
    },
    toggleNamespace(namespace) {
      const index = this.selectedNamespaces.findIndex(id => id === namespace.id);
      if (index > -1) {
        this.$emit('removeSyncOption', { key: 'selectiveSyncNamespaceIds', index });
      } else {
        this.$emit('addSyncOption', { key: 'selectiveSyncNamespaceIds', value: namespace.id });
      }
    },
    isSelected(namespace) {
      return this.selectedNamespaces.includes(namespace.id);
    },
  },
};
</script>

<template>
  <gl-dropdown :text="dropdownTitle" @show="searchNamespaces(namespaceSearch)">
    <gl-search-box-by-type v-model="namespaceSearch" class="m-2" />
    <li v-for="namespace in synchronizationNamespaces" :key="namespace.id">
      <gl-button class="d-flex align-items-center" @click="toggleNamespace(namespace)">
        <gl-icon :class="[{ invisible: !isSelected(namespace) }]" name="mobile-issue-close" />
        <span class="ml-1">{{ namespace.name }}</span>
      </gl-button>
    </li>
    <div v-if="noSyncNamespaces" class="text-secondary p-2">{{ __('Nothing found…') }}</div>
  </gl-dropdown>
</template>
