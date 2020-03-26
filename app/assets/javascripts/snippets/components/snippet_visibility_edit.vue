<script>
import { GlIcon, GlFormGroup, GlFormRadio, GlFormRadioGroup, GlLink } from '@gitlab/ui';
import { SNIPPET_VISIBILITY } from '~/snippets/constants';

export default {
  components: {
    GlIcon,
    GlFormGroup,
    GlFormRadio,
    GlFormRadioGroup,
    GlLink,
  },
  props: {
    helpLink: {
      type: String,
      default: '',
      required: false,
    },
    isProjectSnippet: {
      type: Boolean,
      required: false,
      default: false,
    },
    value: {
      type: Number,
      required: true,
    },
  },
  computed: {
    visibilityOptions() {
      return [
        {
          value: 0,
          icon: 'lock',
          text: SNIPPET_VISIBILITY.private.label,
          description: this.isProjectSnippet
            ? SNIPPET_VISIBILITY.private.description_project
            : SNIPPET_VISIBILITY.private.description,
        },
        {
          value: 10,
          icon: 'shield',
          text: SNIPPET_VISIBILITY.internal.label,
          description: SNIPPET_VISIBILITY.internal.description,
        },
        {
          value: 20,
          icon: 'earth',
          text: SNIPPET_VISIBILITY.public.label,
          description: SNIPPET_VISIBILITY.public.description,
        },
      ];
    },
  },
};
</script>
<template>
  <div class="form-group">
    <label>
      {{ __('Visibility level') }}
      <gl-link v-if="helpLink" :href="helpLink" target="_blank"
        ><gl-icon :size="12" name="question"
      /></gl-link>
    </label>
    <gl-form-group id="visibility-level-setting">
      <gl-form-radio-group v-bind="$attrs" :checked="value" stacked v-on="$listeners">
        <gl-form-radio
          v-for="option in visibilityOptions"
          :key="option.icon"
          :value="option.value"
          class="mb-3"
        >
          <div class="d-flex align-items-center">
            <gl-icon :size="16" :name="option.icon" />
            <span class="font-weight-bold ml-1">{{ option.text }}</span>
          </div>
          <template #help>{{ option.description }}</template>
        </gl-form-radio>
      </gl-form-radio-group>
    </gl-form-group>
  </div>
</template>
