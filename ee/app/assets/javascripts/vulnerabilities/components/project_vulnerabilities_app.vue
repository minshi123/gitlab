<script>
import { s__ } from '~/locale';
import { GlAlert, GlDeprecatedButton, GlEmptyState, GlIntersectionObserver } from '@gitlab/ui';
import SelectionSummary from 'ee/security_dashboard/components/selection_summary.vue';
import VulnerabilityList from 'ee/vulnerabilities/components/vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphql/project_vulnerabilities.graphql';
import { VULNERABILITIES_PER_PAGE } from '../constants';

export default {
  name: 'ProjectVulnerabilitiesApp',
  components: {
    GlAlert,
    GlDeprecatedButton,
    GlEmptyState,
    GlIntersectionObserver,
    SelectionSummary,
    VulnerabilityList,
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
    projectFullPath: {
      type: String,
      required: true,
    },
    filters: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      pageInfo: {},
      vulnerabilities: [],
      errorLoadingVulnerabilities: false,
      // TODO: Make this an object to be able to add/subtract from easier
      selectedVulnerabilities: [],
    };
  },
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      variables() {
        return {
          fullPath: this.projectFullPath,
          first: VULNERABILITIES_PER_PAGE,
          ...this.filters,
        };
      },
      update: ({ project }) => project.vulnerabilities.nodes,
      result({ data }) {
        this.pageInfo = data.project.vulnerabilities.pageInfo;
      },
      error() {
        this.errorLoadingVulnerabilities = true;
      },
    },
  },
  computed: {
    isLoadingVulnerabilities() {
      return this.$apollo.queries.vulnerabilities.loading;
    },
    isLoadingFirstVulnerabilities() {
      return this.isLoadingVulnerabilities && this.vulnerabilities.length === 0;
    },
  },
  methods: {
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.vulnerabilities.fetchMore({
          variables: { after: this.pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const newResult = { ...fetchMoreResult };
            previousResult.project.vulnerabilities.nodes.push(
              ...fetchMoreResult.project.vulnerabilities.nodes,
            );
            newResult.project.vulnerabilities.nodes = previousResult.project.vulnerabilities.nodes;
            return newResult;
          },
        });
      }
    },
    toggleAllVulnerabilities() {
      console.log('all-vulnerability: ', this.vulnerabilities);
      if (this.selectedVulnerabilities.length) {
        this.selectedVulnerabilities = [];
      } else {
        this.selectedVulnerabilities = [...this.vulnerabilities];
      }
    },
    toggleVulnerability(vulnerability) {
      // TODO fix this
      console.log('vulnerability: ', vulnerability);
      this.selectedVulnerabilities.push(vulnerability);
    },
  },
  emptyStateDescription: s__(
    `While it's rare to have no vulnerabilities for your project, it can happen. In any event, we ask that you double check your settings to make sure you've set up your dashboard correctly.`,
  ),
};
</script>

<template>
  <div>
    <selection-summary
      v-if="selectedVulnerabilities.length"
      :selected-vulnerabilities="selectedVulnerabilities"
    />
    <gl-alert v-if="errorLoadingVulnerabilities" :dismissible="false" variant="danger">
      {{
        s__(
          'Security Dashboard|Error fetching the vulnerability list. Please check your network connection and try again.',
        )
      }}
    </gl-alert>
    <vulnerability-list
      v-else
      :is-loading="isLoadingFirstVulnerabilities"
      :dashboard-documentation="dashboardDocumentation"
      :empty-state-svg-path="emptyStateSvgPath"
      :vulnerabilities="vulnerabilities"
      :toggle-vulnerability="toggleVulnerability"
      :toggle-all-vulnerabilities="toggleAllVulnerabilities"
    >
      <template #emptyState>
        <gl-empty-state
          :title="s__(`No vulnerabilities found for this project`)"
          :svg-path="emptyStateSvgPath"
          :description="$options.emptyStateDecription"
          :primary-button-link="dashboardDocumentation"
          :primary-button-text="s__('Security Reports|Learn more about setting up your dashboard')"
        />
      </template>
    </vulnerability-list>
    <gl-intersection-observer
      v-if="pageInfo.hasNextPage"
      class="text-center"
      @appear="fetchNextPage"
    >
      <gl-deprecated-button
        :loading="isLoadingVulnerabilities"
        :disabled="isLoadingVulnerabilities"
        @click="fetchNextPage"
        >{{ __('Load more vulnerabilities') }}</gl-deprecated-button
      >
    </gl-intersection-observer>
  </div>
</template>
