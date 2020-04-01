<script>
import { __ } from '~/locale';
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
  methods: {
    translate: __,
  },
};
</script>

<template>
  <div>
    <div>
      <h3>{{ translate('Success!') }}</h3>
      <p>
        {{
          translate(
            "Your changes have been submitted and a merge request has been created. The changes won't be visible on the site until the merge request has been accepted.",
          )
        }}
      </p>
      <div>
        <gl-new-button :href="returnUrl">{{ translate('Return to site') }}</gl-new-button>
        <gl-new-button :href="links.mergeRequest.url" variant="info">{{
          translate('View merge request')
        }}</gl-new-button>
      </div>
    </div>

    <hr />

    <div>
      <h4>{{ translate('Summary of changes') }}</h4>
      <ul>
        <li>
          {{ translate('A new branch was created:') }}
          <gl-link :href="links.branch.url">{{ links.branch.label }}</gl-link>
        </li>
        <li>
          {{ translate('Your changes were committed to it:') }}
          <gl-link :href="links.commit.url">{{ links.commit.label }}</gl-link>
        </li>
        <li>
          {{ translate('A merge request was created:') }}
          <gl-link :href="links.mergeRequest.url">{{ links.mergeRequest.label }}</gl-link>
        </li>
      </ul>
    </div>
  </div>
</template>
