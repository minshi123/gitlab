<script>
import { s__ } from '~/locale';
import { GlSprintf } from '@gitlab/ui';

export default {
  components: {
    GlSprintf,
  },
  props: {
    helpPath: {
      type: String,
      required: false,
      default: null,
    },
    lfsEnabled: {
      type: Boolean,
      required: true,
    },
    hasLfsObjects: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      label: s__('ProjectSettings|Git Large File Storage'),
      helpText: s__('ProjectSettings|Manages large files such as audio, video, and graphics files'),
    };
  },
};
</script>

<template>
  <div class="project-feature-row">
    <label v-if="label" class="label-bold">
      {{ label }}
      <a v-if="helpPath" :href="helpPath" target="_blank">
        <i aria-hidden="true" data-hidden="true" class="fa fa-question-circle"> </i>
      </a>
    </label>
    <span v-if="helpText" class="form-text text-muted"> {{ helpText }} </span> <slot></slot>
    <p v-if="!lfsEnabled && hasLfsObjects">
      <gl-sprintf
        :message="
          s__(
            'ProjectSettings|The LFS objects from this repository are still accessible to any forks with LFS enabled. %{linkStart}How do I remove them from this repository and forks?%{linkEnd}',
          )
        "
      >
        <template #link="{ content }">
          <br />
          <a href="Some Link To Docs About Removing LFS Files">{{ content }}</a>
        </template>
      </gl-sprintf>
    </p>
  </div>
</template>
