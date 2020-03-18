<script>
import { s__ } from '~/locale';
import { mapActions, mapState } from 'vuex';
import { GlIcon, GlDropdown, GlDropdownHeader, GlDropdownItem } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
    GlDropdown,
    GlDropdownHeader,
    GlDropdownItem,
  },
  props: {
    disabled: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      searchQuery: '',
    };
  },
  computed: {
    ...mapState('environmentLogs', ['pods']),

    podDropdownText() {
      if (this.pods.current) {
        return this.pods.current;
      }
      return s__('Environments|No pod selected');
    },
  },
  methods: {
    ...mapActions('environmentLogs', ['showPodLogs']),
  },
};
</script>
<template>
  <div>
    <gl-dropdown
      id="pods-dropdown"
      :text="podDropdownText"
      :disabled="disabled"
      class="gl-h-32 js-pods-dropdown"
      toggle-class="dropdown-menu-toggle"
    >
      <gl-dropdown-header class="text-center">
        {{ s__('Environments|Select pod') }}
      </gl-dropdown-header>

      <gl-dropdown-item v-if="!pods.options.length" :disabled="true">
        <span class="text-muted">
          {{ s__('Environments|No pods to display') }}
        </span>
      </gl-dropdown-item>
      <gl-dropdown-item
        v-for="podName in pods.options"
        :key="podName"
        class="text-nowrap"
        @click="showPodLogs(podName)"
      >
        <div class="d-flex">
          <gl-icon
            :class="{ invisible: podName !== pods.current }"
            name="status_success_borderless"
          />
          <div class="flex-grow-1">{{ podName }}</div>
        </div>
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
