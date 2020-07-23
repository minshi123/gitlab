<script>
import { GlLink, GlSprintf } from '@gitlab/ui';

import { __ } from '~/locale';

export default {
  components: {
    GlLink,
    GlSprintf,
  },
  props: {
    sourceBranch: {
      type: Object,
      required: true,
    },
    targetBranch: {
      type: Object,
      required: true,
    },
  },
  strings: {
    branchDetails: __('%{sourceBranch} into %{targetBranch}'),
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center gl-justify-content-end">
    <gl-sprintf :message="this.$options.strings.branchDetails">
      <template #sourceBranch>
        <span class="gl-mr-2">
          <gl-link
            v-if="sourceBranch.uri"
            :href="targetBranch.uri"
            data-testid="source-branch-uri"
            >{{ sourceBranch.name }}</gl-link
          >
          <span v-else>{{ sourceBranch.name }}</span>
        </span>
      </template>
      <template #targetBranch>
        <span class="gl-ml-2">
          <gl-link
            v-if="targetBranch.uri"
            :href="targetBranch.uri"
            data-testid="target-branch-uri"
            >{{ targetBranch.name }}</gl-link
          >
          <span v-else>{{ targetBranch.name }}</span>
        </span>
      </template>
    </gl-sprintf>
  </div>
</template>
