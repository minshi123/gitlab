<script>
import { s__ } from '~/locale';
import { GlAlert, GlButton, GlEmptyState, GlIntersectionObserver } from '@gitlab/ui';
import VulnerabilityList from 'ee/vulnerabilities/components/vulnerability_list.vue';
import vulnerabilitiesQuery from 'ee/vulnerabilities/graphql/vulnerabilities.gql';
import { VULNERABILITIES_PER_PAGE } from 'ee/vulnerabilities/constants';

// TODO: Make this more dashboardy
export default {
  name: 'VulnerabilitiesApp',
  components: {
    GlAlert,
    GlButton,
    GlEmptyState,
    GlIntersectionObserver,
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
  },
  data: () => ({
    pageInfo: {},
    vulnerabilities: [],
    initialVulnerabilitiesLoad: false,
    errorLoadingVulnerabilities: false,
  }),
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      variables() {
        return {
          fullPath: this.projectFullPath,
          first: VULNERABILITIES_PER_PAGE,
        };
      },
      update: data => data?.project?.vulnerabilities?.nodes || [],
      result(res) {
        this.initialVulnerabilitiesLoad = true;
        this.pageInfo = res?.data?.project?.vulnerabilities?.pageInfo || {};
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
  },
  methods: {
    nextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.vulnerabilities.fetchMore({
          variables: {
            first: VULNERABILITIES_PER_PAGE,
            after: this.pageInfo.endCursor,
          },
          updateQuery: (prev, { fetchMoreResult }) => {
            const result = { ...fetchMoreResult };
            result.project.vulnerabilities.nodes = [
              ...prev.project.vulnerabilities.nodes,
              ...fetchMoreResult.project.vulnerabilities.nodes,
            ];
            return result;
          },
        });
      }
    },
  },
  emptyStateDescription: s__(
    `While it's rare to have no vulnerabilities for your project, it can happen. In any event, we ask that you double check your settings to make sure you've set up your dashboard correctly.`,
  ),
};
</script>

<template>
  <div>
    <gl-alert v-if="errorLoadingVulnerabilities" :dismissible="false" variant="danger">
      {{
        s__(
          'Security Dashboard|Error fetching the vulnerability list. Please check your network connection and try again.',
        )
      }}
    </gl-alert>
    <vulnerability-list
      v-else
      :is-loading="!initialVulnerabilitiesLoad"
      :dashboard-documentation="dashboardDocumentation"
      :empty-state-svg-path="emptyStateSvgPath"
      :vulnerabilities="vulnerabilities"
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
    <gl-intersection-observer v-if="pageInfo.hasNextPage" class="text-center" @appear="nextPage">
      <gl-button
        :loading="isLoadingVulnerabilities"
        :disabled="isLoadingVulnerabilities"
        @click="nextPage"
        >{{ __('Load more vulnerabilities') }}</gl-button
      >
    </gl-intersection-observer>
  </div>
</template>
