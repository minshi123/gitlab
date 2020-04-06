<script>
import { GlNewButton } from '@gitlab/ui';

// TODO make this a functional component?
export default {
  name: 'JiraImportSetup',
  components: {
    GlNewButton,
  },
};
</script>

<template>
  <div class="empty-state">
    <div class="svg-content">SVG illustration</div>
    <div class="text-content d-flex flex-column align-items-center">
      <p>{{ __('You will first need to set up Jira Integration to use this feature.') }}</p>
      <a class="btn btn-success" href="../services/jira/edit">
        {{ __('Set up Jira Integration') }}
      </a>
    </div>
  </div>
</template>
