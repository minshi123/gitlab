<script>
import * as Sentry from '@sentry/browser';
import { GlLoadingIcon, GlPagination } from '@gitlab/ui';
import { __ } from '~/locale';
import createFlash from '~/flash';
import { updateHistory } from '~/lib/utils/url_utility';

import RequirementsEmptyState from './requirements_empty_state.vue';
import RequirementItem from './requirement_item.vue';
import projectRequirements from '../queries/projectRequirements.query.graphql';

import { FilterState, DefaultPageSize } from '../constants';

export default {
  DefaultPageSize,
  components: {
    GlPagination,
    GlLoadingIcon,
    RequirementsEmptyState,
    RequirementItem,
  },
  props: {
    projectPath: {
      type: String,
      required: true,
    },
    filterBy: {
      type: String,
      required: true,
    },
    showCreateRequirement: {
      type: Boolean,
      required: true,
    },
    emptyStatePath: {
      type: String,
      required: true,
    },
  },
  apollo: {
    requirements: {
      query: projectRequirements,
      variables() {
        const queryVariables = {
          projectPath: this.projectPath,
          prevPageCursor: this.prevPageCursor,
          nextPageCursor: this.nextPageCursor,
        };

        if (this.filterBy !== FilterState.all) {
          queryVariables.state = this.filterBy;
        }

        return queryVariables;
      },
      update(data) {
        const requirementsRoot = data.project?.requirements;

        return {
          list: requirementsRoot?.nodes || [],
          pageInfo: requirementsRoot?.pageInfo || {},
          count: data.project?.requirementStatesCount || {},
        };
      },
      error: e => {
        createFlash(__('Something went wrong while fetching requirements list.'));
        Sentry.captureException(e);
      },
    },
  },
  data() {
    return {
      page: 1,
      prevPageCursor: '',
      nextPageCursor: '',
      requirements: null,
    };
  },
  computed: {
    requirementsListLoading() {
      return this.$apollo.queries.requirements.loading;
    },
    requirementsListEmpty() {
      return !this.$apollo.queries.requirements.loading && !this.requirements.list.length;
    },
    totalRequirements() {
      return this.requirements?.count.opened + this.requirements?.count.archived;
    },
  },
  methods: {
    updateUrl(page) {
      const { href, search } = window.location;
      let url = href;

      if (!search) {
        url = `${url}?page=${page}`;
      } else if (search.includes('page')) {
        url = url.replace(/page=\d+/g, `page=${page}`);
      } else {
        url = `${url}&page=${page}`;
      }

      updateHistory({ state: { path: url }, url });
    },
    handlePageChange(page) {
      if (page > this.page) {
        this.prevPageCursor = '';
        this.nextPageCursor = this.requirements.pageInfo.endCursor;
      } else {
        this.prevPageCursor = this.requirements.pageInfo.startCursor;
        this.nextPageCursor = '';
      }
      this.page = page;
      this.updateUrl(page);
    },
  },
};
</script>

<template>
  <div class="requirements-list-container">
    <requirements-empty-state
      v-if="requirementsListEmpty"
      :filter-by="filterBy"
      :empty-state-path="emptyStatePath"
    />
    <gl-loading-icon v-if="requirementsListLoading" class="mt-3" size="md" />
    <ul v-else class="content-list issuable-list issues-list requirements-list">
      <requirement-item
        v-for="requirement in requirements.list"
        :key="requirement.iid"
        :requirement="requirement"
      />
    </ul>
    <div v-if="totalRequirements" class="gl-pagination prepend-top-default">
      <gl-pagination
        :value="page"
        :per-page="$options.DefaultPageSize"
        :total-items="totalRequirements"
        align="center"
        @input="handlePageChange"
      />
    </div>
  </div>
</template>
