<script>
import { GlLink, GlNewButton } from '@gitlab/ui';

const urlAndLabelValidator = value => {
  return (
    Object.prototype.hasOwnProperty.call(value, 'label') &&
    Object.prototype.hasOwnProperty.call(value, 'url')
  );
};

export default {
  components: {
    GlLink,
    GlNewButton,
  },
  props: {
    branch: { type: Object, required: true, validator: urlAndLabelValidator },
    commit: { type: Object, required: true, validator: urlAndLabelValidator },
    mergeRequest: { type: Object, required: true, validator: urlAndLabelValidator },
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
        <gl-new-button ref="returnToSiteNewButton" :href="returnUrl">{{
          s__('StaticSiteEditor|Return to site')
        }}</gl-new-button>
        <gl-new-button ref="mergeRequestNewButton" :href="mergeRequest.url" variant="info">{{
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
          <gl-link ref="branchLink" :href="branch.url">{{ branch.label }}</gl-link>
        </li>
        <li>
          {{ s__('StaticSiteEditor|Your changes were committed to it:') }}
          <gl-link ref="commitLink" :href="commit.url">{{ commit.label }}</gl-link>
        </li>
        <li>
          {{ s__('StaticSiteEditor|A merge request was created:') }}
          <gl-link ref="mergeRequestLink" :href="mergeRequest.url">{{
            mergeRequest.label
          }}</gl-link>
        </li>
      </ul>
    </div>
  </div>
</template>
