<script>
import {
  GlIcon,
  // GlLoadingIcon,
  // GlButton,
  GlAvatar,
  GlDropdown,
  GlDropdownHeader,
  GlDropdownItem,
  GlSearchBoxByType,
} from '@gitlab/ui';
import { n__, s__, __ } from '~/locale';
import Api from '~/api';

export default {
  name: 'ProjectsDropdownFilter',
  components: {
    GlIcon,
    // GlLoadingIcon,
    // GlButton,
    GlAvatar,
    GlDropdown,
    GlDropdownHeader,
    GlDropdownItem,
    GlSearchBoxByType,
  },
  props: {
    groupId: {
      type: Number,
      required: true,
    },
    multiSelect: {
      type: Boolean,
      required: false,
      default: false,
    },
    label: {
      type: String,
      required: false,
      default: s__('CycleAnalytics|project dropdown filter'),
    },
    queryParams: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    defaultProjects: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      loading: true,
      projects: [],
      selectedProjects: this.defaultProjects || [],
      searchTerm: '',
    };
  },
  computed: {
    selectedProjectsLabel() {
      if (this.selectedProjects.length === 1) {
        return this.selectedProjects[0].name;
      } else if (this.selectedProjects.length > 1) {
        return n__(
          'CycleAnalytics|Project selected',
          'CycleAnalytics|%d projects selected',
          this.selectedProjects.length,
        );
      }

      return this.selectedProjectsPlaceholder;
    },
    selectedProjectsPlaceholder() {
      return this.multiSelect ? __('Select projects') : __('Select a project');
    },
    isOnlyOneProjectSelected() {
      return this.selectedProjects.length === 1;
    },
    selectedProjectIds() {
      return this.selectedProjects.map(p => p.id);
    },
    availableProjects() {
      return this.projects.filter(({ name }) =>
        name.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    getSelectedProjects(selectedProject, isMarking) {
      return isMarking
        ? this.selectedProjects.concat([selectedProject])
        : this.selectedProjects.filter(project => project.id !== selectedProject.id);
    },
    singleSelectedProject(selectedObj, isMarking) {
      return isMarking ? [selectedObj] : [];
    },
    setSelectedProjects(selectedObj, isMarking) {
      this.selectedProjects = this.multiSelect
        ? this.getSelectedProjects(selectedObj, isMarking)
        : this.singleSelectedProject(selectedObj, isMarking);
    },
    onClick({ project, isSelected }) {
      this.setSelectedProjects(project, !isSelected);
      this.$emit('selected', this.selectedProjects);
    },
    fetchData() {
      this.loading = true;
      return Api.groupProjects(this.groupId, this.searchTerm, this.queryParams, projects => {
        this.projects = projects;
        this.loading = false;
      });
    },
    isProjectSelected(id) {
      return this.selectedProjects ? this.selectedProjectIds.includes(id) : false;
    },
  },
};
</script>

<template>
  <div>
    <gl-dropdown
      ref="projectsDropdown"
      class="dropdown dropdown-projects wide shadow-none bg-white"
    >
      <template #button-content>
        <div class="d-flex">
          <gl-avatar
            v-if="isOnlyOneProjectSelected"
            :src="selectedProjects[0].avatar_url"
            :entity-id="selectedProjects[0].id"
            :entity-name="selectedProjects[0].name"
            :size="16"
            shape="rect"
            :alt="selectedProjects[0].name"
            class="d-inline-flex vertical-align-middle mr-2"
          />
          {{ selectedProjectsLabel }}
          <gl-icon name="chevron-down" />
        </div>
      </template>
      <gl-dropdown-header>{{ __('Projects') }}</gl-dropdown-header>
      <gl-search-box-by-type v-model.trim="searchTerm" class="m-2" />
      <gl-dropdown-item
        v-for="project in availableProjects"
        :key="project.id"
        :active="isProjectSelected(project.id)"
        @click.prevent="onClick({ project, isSelected: isProjectSelected(project.id) })"
      >
        <!-- move to component? -->
        <div class="d-flex">
          <gl-icon
            v-if="isProjectSelected(project.id)"
            class="text-gray-700 mr-2 vertical-align-middle"
            name="mobile-issue-close"
          />
          <gl-avatar
            class="mr-2"
            :class="{ 'pl-4': !isProjectSelected(label.id) }"
            :size="16"
            :entity-name="project.name"
            :src="project.avatar_url"
            shape="rect"
          />
          {{ project.name }}
        </div>
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
