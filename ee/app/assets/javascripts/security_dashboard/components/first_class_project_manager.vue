<script>
import createFlash from '~/flash';
import { __, s__, sprintf } from '~/locale';
import { GlDeprecatedButton } from '@gitlab/ui';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';
import ProjectList from './project_list.vue';
import getProjects from 'ee/security_dashboard/graphql/get_projects.query.graphql';
import getInstanceSecurityDashboardProjects from 'ee/security_dashboard/graphql/get_instance_security_dashboard_projects.query.graphql';
import addProjectToSecurityDashboard from 'ee/security_dashboard/graphql/add_project_to_security_dashboard.mutation.graphql';
import deleteProjectFromSecurityDashboard from 'ee/security_dashboard/graphql/delete_project_from_security_dashboard.mutation.graphql';

const API_MINIMUM_QUERY_LENGTH = 3;
const PROJECTS_PER_PAGE = 20;

export default {
  components: {
    GlDeprecatedButton,
    ProjectList,
    ProjectSelector,
  },
  props: {
    isManipulatingProjects: {
      type: Boolean,
      required: true,
    },
    projects: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      inputValue: '',
      searchQuery: '',
      projectSearchResults: [],
      selectedProjects: [],
      messages: {
        noResults: false,
        searchError: false,
        minimumQuery: false,
      },
      searchCount: 0,
      pageInfo: {
        endCursor: '',
        hasNextPage: true,
      },
    };
  },
  computed: {
    canAddProjects() {
      return !this.isManipulatingProjects && this.selectedProjects.length > 0;
    },
    isSearchingProjects() {
      return this.searchCount > 0;
    },
  },
  methods: {
    searchProjects(searchQuery, pageInfo) {
      return this.$apollo.query({
        query: getProjects,
        variables: { search: searchQuery, first: PROJECTS_PER_PAGE, after: pageInfo.endCursor },
      });
    },
    processAddProjectResponse(response, selectedProjects) {
      return response.reduce(
        (acc, curr, i) => {
          const project = curr?.data.addProjectToSecurityDashboard.project;

          if (project) {
            acc.added.push(project);
          } else {
            acc.invalid.push(selectedProjects[i].id);
          }

          return acc;
        },
        { added: [], invalid: [] },
      );
    },
    toggleSelectedProject(project) {
      const isProject = ({ id }) => id === project.id;

      if (this.selectedProjects.some(isProject)) {
        this.selectedProjects = this.selectedProjects.filter(p => p.id !== project.id);
      } else {
        this.selectedProjects.push(project);
      }
    },
    addProjects() {
      this.$emit('handleProjectManipulation', true);

      const addProjectsPromises = this.selectedProjects.map(p => {
        return this.$apollo
          .mutate({
            mutation: addProjectToSecurityDashboard,
            variables: { id: p.id },
            update(
              store,
              {
                data: {
                  addProjectToSecurityDashboard: { project },
                },
              },
            ) {
              const data = store.readQuery({
                query: getInstanceSecurityDashboardProjects,
              });

              data.instanceSecurityDashboard.projects.nodes.push(project);
              store.writeQuery({ query: getInstanceSecurityDashboardProjects, data });
            },
          })
          .catch(() => {});
      });

      return Promise.all(addProjectsPromises)
        .then(response => {
          const projects = this.processAddProjectResponse(response, this.selectedProjects);
          return this.receiveAddProjectsSuccess(projects);
        })
        .finally(() => {
          this.projectSearchResults = [];
          this.selectedProjects = [];
        });
    },
    receiveAddProjectsSuccess(data) {
      const { added, invalid } = data;
      this.$emit('handleProjectManipulation', false);

      if (invalid.length) {
        const [firstProject, secondProject, ...rest] = this.selectedProjects
          .filter(project => invalid.includes(project.id))
          .map(project => project.name);
        const translationValues = {
          firstProject,
          secondProject,
          rest: rest.join(', '),
        };
        let invalidProjects;
        if (rest.length > 0) {
          invalidProjects = sprintf(
            s__('SecurityReports|%{firstProject}, %{secondProject}, and %{rest}'),
            translationValues,
          );
        } else if (secondProject) {
          invalidProjects = sprintf(
            s__('SecurityReports|%{firstProject} and %{secondProject}'),
            translationValues,
          );
        } else {
          invalidProjects = firstProject;
        }
        createFlash(
          sprintf(s__('SecurityReports|Unable to add %{invalidProjects}'), {
            invalidProjects,
          }),
        );
      }
    },
    removeProject(projectId) {
      this.$emit('handleProjectManipulation', true);

      this.$apollo
        .mutate({
          mutation: deleteProjectFromSecurityDashboard,
          variables: { id: projectId },
          update(store) {
            const data = store.readQuery({
              query: getInstanceSecurityDashboardProjects,
            });

            data.instanceSecurityDashboard.projects.nodes = data.instanceSecurityDashboard.projects.nodes.filter(
              project => project.id !== projectId,
            );

            store.writeQuery({ query: getInstanceSecurityDashboardProjects, data });
          },
        })
        .then(() => {
          this.$emit('handleProjectManipulation', false);
        })
        .catch(() => createFlash(__('Something went wrong, unable to remove project')));
    },
    fetchSearchResults() {
      this.messages.minimumQuery = false;
      this.searchCount += 1;

      if (!this.searchQuery || this.searchQuery.length < API_MINIMUM_QUERY_LENGTH) {
        this.projectSearchResults = [];
        this.pageInfo.endCursor = '';
        this.pageInfo.hasNextPage = true;
        this.messages.noResults = false;
        this.messages.searchError = false;
        this.messages.minimumQuery = true;
        this.searchCount = Math.max(0, this.searchCount - 1);
      }

      return this.searchProjects(this.searchQuery, this.pageInfo)
        .then(payload => {
          const {
            data: {
              projects: { nodes, pageInfo },
            },
          } = payload;

          this.projectSearchResults = nodes;
          this.pageInfo = pageInfo;
          this.messages.noResults = this.projectSearchResults.length === 0;
          this.messages.searchError = false;
          this.messages.minimumQuery = false;
          this.searchCount = Math.max(0, this.searchCount - 1);
        })
        .catch(() => {
          this.projectSearchResults = [];
          this.messages.noResults = false;
          this.messages.searchError = true;
          this.messages.minimumQuery = false;
          this.searchCount = Math.max(0, this.searchCount - 1);
        });
    },
    fetchSearchResultsNextPage() {
      const {
        searchQuery,
        pageInfo: { hasNextPage, endCursor },
      } = this;

      if (!hasNextPage) {
        return Promise.resolve();
      }

      return this.searchProjects(searchQuery, { hasNextPage, endCursor })
        .then(payload => {
          const {
            data: {
              projects: { nodes, pageInfo },
            },
          } = payload;
          this.projectSearchResults = this.projectSearchResults.concat(nodes);
          this.pageInfo = pageInfo;
        })
        .catch(() => {
          this.projectSearchResults = [];
          this.messages.noResults = false;
          this.messages.searchError = true;
          this.messages.minimumQuery = false;
          this.searchCount = Math.max(0, this.searchCount - 1);
        });
    },
    searched(query) {
      this.searchQuery = query;
      this.fetchSearchResults();
    },
    projectClicked(project) {
      this.toggleSelectedProject(project);
    },
    projectRemoved(project) {
      this.removeProject(project.id);
    },
  },
};
</script>

<template>
  <section class="container">
    <div class="row justify-content-center mt-md-4">
      <div class="col col-lg-7">
        <h3 class="text-3 font-weight-bold border-bottom mb-4 pb-3">
          {{ s__('SecurityReports|Add or remove projects from your dashboard') }}
        </h3>
        <div class="d-flex flex-column flex-md-row">
          <project-selector
            class="flex-grow mr-md-2"
            :project-search-results="projectSearchResults"
            :selected-projects="selectedProjects"
            :show-no-results-message="messages.noResults"
            :show-loading-indicator="isSearchingProjects"
            :show-minimum-search-query-message="messages.minimumQuery"
            :show-search-error-message="messages.searchError"
            @searched="searched"
            @projectClicked="projectClicked"
            @bottomReached="fetchSearchResultsNextPage"
          />
          <div class="mb-3">
            <gl-deprecated-button
              :disabled="!canAddProjects"
              variant="success"
              @click="addProjects"
            >
              {{ s__('SecurityReports|Add projects') }}
            </gl-deprecated-button>
          </div>
        </div>
      </div>
    </div>
    <div class="row justify-content-center mt-md-3">
      <project-list
        :projects="projects"
        :show-loading-indicator="isManipulatingProjects"
        class="col col-lg-7"
        @projectRemoved="projectRemoved"
      />
    </div>
  </section>
</template>
