<script>
import { GlLoadingIcon, GlEmptyState } from '@gitlab/ui';

import RequirementItem from './requirement_item.vue';
import projectRequirements from '../queries/projectRequirements.query.graphql';

import { FilterState } from '../constants';

export default {
  components: {
    GlLoadingIcon,
    GlEmptyState,
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
        };

        if (this.filterBy !== FilterState.all) {
          queryVariables.state = this.filterBy;
        }

        return queryVariables;
      },
      update: data => data.project.requirements.nodes,
    },
  },
  data() {
    return {
      requirements: [],
    };
  },
  computed: {
    requirementsListLoading() {
      return this.$apolloData.loading > 0;
    },
    requirementsListEmpty() {
      return !this.$apolloData.loading && !this.requirements.length;
    },
  },
};
</script>

<template>
  <div class="card card-small card-without-border">
    <gl-empty-state
      v-if="requirementsListEmpty"
      :title="__('No requirements available for current state')"
      :svg-path="emptyStatePath"
    />
    <gl-loading-icon v-if="requirementsListLoading" class="mt-3" size="md" />
    <ul v-else class="content-list issuable-list">
      <requirement-item
        v-for="requirement in requirements"
        :key="requirement.iid"
        :requirement="requirement"
      />
    </ul>
  </div>
</template>
