<script>
import { GlLink, GlNewButton } from '@gitlab/ui';

export default {
  components: {
    GlLink,
    GlNewButton,
  },
  props: {
    links: { type: Object, required: true },
    returnUrl: { type: String, required: true },
  },
};
</script>

<template>
  <div>
    <div>
      <h3>{{ s__('StaticSiteEditor|Success!') }}</h3>
      <p>
        {{
          s__(
            "StaticSiteEditor|Your changes have been submitted and a merge request has been created. The changes won't be visible on the site until the merge request has been accepted.",
          )
        }}
      </p>
      <div>
        <gl-new-button :href="returnUrl">{{
          s__('StaticSiteEditor|Return to site')
        }}</gl-new-button>
        <gl-new-button :href="links.mergeRequest.url" variant="info">{{
          s__('StaticSiteEditor|View merge request')
        }}</gl-new-button>
      </div>
    </div>

    <hr />

    <div>
      <h4>{{ s__('StaticSiteEditor|Summary of changes') }}</h4>
      <ul>
        <li>
          {{ s__('StaticSiteEditor|A new branch was created:') }}
          <gl-link :href="links.branch.url">{{ links.branch.label }}</gl-link>
        </li>
        <li>
          {{ s__('StaticSiteEditor|Your changes were committed to it:') }}
          <gl-link :href="links.commit.url">{{ links.commit.label }}</gl-link>
        </li>
        <li>
          {{ s__('StaticSiteEditor|A merge request was created:') }}
          <gl-link :href="links.mergeRequest.url">{{ links.mergeRequest.label }}</gl-link>
        </li>
      </ul>
    </div>
  </div>
</template>
