<script>
import { s__ } from '~/locale';
import { GlAlert, GlButton, GlEmptyState, GlIntersectionObserver } from '@gitlab/ui';
import VulnerabilityList from 'ee/vulnerabilities/components/vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphql/group_vulnerabilities.graphql';
import { VULNERABILITIES_PER_PAGE } from 'ee/vulnerabilities/constants';

export default {
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
    groupFullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      pageInfo: {},
      vulnerabilities: [],
      errorLoadingVulnerabilities: false,
    };
  },
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      variables() {
        return {
          fullPath: this.groupFullPath,
          first: VULNERABILITIES_PER_PAGE,
        };
      },
      update: ({ group }) => group.vulnerabilities.nodes,
      result({ data }) {
        this.pageInfo = data.group.vulnerabilities.pageInfo;
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
    hasVulnerabilities() {
      return !this.isLoadingVulnerabilities && this.vulnerabilities.length > 0;
    },
  },
  methods: {
    onErrorDismiss() {
      this.errorLoadingVulnerabilities = false;
    },
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.vulnerabilities.fetchMore({
          variables: { after: this.pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const newResult = { ...fetchMoreResult };
            previousResult.group.vulnerabilities.nodes.push(
              ...fetchMoreResult.group.vulnerabilities.nodes,
            );
            newResult.group.vulnerabilities.nodes = previousResult.group.vulnerabilities.nodes;
            return newResult;
          },
        });
      }
    },
  },
  emptyStateDescription: s__(
    `While it's rare to have no vulnerabilities for your group, it can happen. In any event, we ask that you double check your settings to make sure you've set up your dashboards correctly.`,
  ),
};
</script>

<template>
  <div>
    <gl-alert
      v-if="errorLoadingVulnerabilities"
      class="mb-4"
      variant="danger"
      @dismiss="onErrorDismiss"
    >
      {{
        s__(
          'Security Dashboard|Error fetching the vulnerability list. Please check your network connection and try again.',
        )
      }}
    </gl-alert>
    <vulnerability-list
      v-else
      :is-loading="isLoadingVulnerabilities"
      :dashboard-documentation="dashboardDocumentation"
      :empty-state-svg-path="emptyStateSvgPath"
      :vulnerabilities="vulnerabilities"
    >
      <template v-if="!hasVulnerabilities" #emptyState>
        <gl-empty-state
          :title="s__(`No vulnerabilities found for this group`)"
          :svg-path="emptyStateSvgPath"
          :description="$options.emptyStateDescription"
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
      <gl-button
        :loading="isLoadingVulnerabilities"
        :disabled="isLoadingVulnerabilities"
        @click="fetchNextPage"
        >{{ __('Load more vulnerabilities') }}</gl-button
      >
    </gl-intersection-observer>
  </div>
</template>
