<script>
import { s__ } from '~/locale';
import { mapActions } from 'vuex';
import { GlDeprecatedButton } from '@gitlab/ui';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import InstanceSecurityVulnerabilities from './first_class_instance_security_dashboard_vulnerabilities.vue';
import ProjectManager from './project_manager.vue';

export default {
  components: {
    GlDeprecatedButton,
    ProjectManager,
    SecurityDashboardLayout,
    InstanceSecurityVulnerabilities,
  },
  props: {
    dashboardDocumentation: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    projectAddEndpoint: {
      type: String,
      required: true,
    },
    projectListEndpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      showProjectSelector: false,
    };
  },
  computed: {
    toggleButtonProps() {
      return this.showProjectSelector
        ? {
            variant: 'success',
            text: s__('SecurityDashboard|Return to dashboard'),
          }
        : {
            variant: 'secondary',
            text: s__('SecurityDashboard|Edit dashboard'),
          };
    },
  },
  created() {
    this.setProjectEndpoints({
      add: this.projectAddEndpoint,
      list: this.projectListEndpoint,
    });
  },
  methods: {
    ...mapActions('projectSelector', ['setProjectEndpoints', 'fetchProjects']),
    toggleProjectSelector() {
      this.showProjectSelector = !this.showProjectSelector;
    },
  },
};
</script>

<template>
  <security-dashboard-layout>
    <template #header>
      <header class="page-title-holder flex-fill d-flex align-items-center">
        <h2 class="page-title">{{ s__('SecurityDashboard|Security Dashboard') }}</h2>
        <gl-deprecated-button
          class="page-title-controls js-project-selector-toggle"
          :variant="toggleButtonProps.variant"
          @click="toggleProjectSelector"
          v-text="toggleButtonProps.text"
        />
      </header>
    </template>
    <project-manager v-if="showProjectSelector" />
    <instance-security-vulnerabilities
      v-else
      :dashboard-documentation="dashboardDocumentation"
      :empty-state-svg-path="emptyStateSvgPath"
    />
  </security-dashboard-layout>
</template>
