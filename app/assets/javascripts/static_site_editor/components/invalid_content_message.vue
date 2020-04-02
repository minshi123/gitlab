<script>
import { GlNewButton } from '@gitlab/ui';

export default {
  components: {
    GlNewButton,
  },
  props: {
    configureUrl: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <h3>{{ s__('StaticSiteEditor|Incompatible file content') }}</h3>
    <p>
      {{
        s__(
          'StaticSiteEditor|The Static Site Editor is currently configured to only edit Markdown content on pages generated from Middleman. Visit the documentation for the feature to learn more about configuring your site to use the Static Site Editor.',
        )
      }}
    </p>
    <div>
      <gl-new-button ref="configureSiteButton" :href="configureUrl">{{
        s__('StaticSiteEditor|Configure your static site')
      }}</gl-new-button>
    </div>
  </div>
</template>
