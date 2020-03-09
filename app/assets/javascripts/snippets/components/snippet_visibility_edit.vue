<script>
import { GlIcon, GlFormGroup, GlFormRadio, GlFormRadioGroup } from '@gitlab/ui';
import {
  SNIPPET_VISIBILITY_PRIVATE_LABEL,
  SNIPPET_VISIBILITY_INTERNAL_LABEL,
  SNIPPET_VISIBILITY_PUBLIC_LABEL,
  SNIPPET_VISIBILITY_PRIVATE_DESCRIPTION_PERSONAL,
  SNIPPET_VISIBILITY_PRIVATE_DESCRIPTION_PROJECT,
  SNIPPET_VISIBILITY_INTERNAL_DESCRIPTION,
  SNIPPET_VISIBILITY_PUBLIC_DESCRIPTION,
} from '~/snippets/constants';

export default {
  components: {
    GlIcon,
    GlFormGroup,
    GlFormRadio,
    GlFormRadioGroup,
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
    visibilityLevel: {
      type: String,
      default: '0',
      required: false,
    },
  },
  data() {
    return {
      selected: this.visibilityLevel,
    };
  },
  computed: {
    visibilityOptions() {
      return [
        {
          value: '0',
          icon: 'lock',
          text: SNIPPET_VISIBILITY_PRIVATE_LABEL,
          description: this.isProjectSnippet
            ? SNIPPET_VISIBILITY_PRIVATE_DESCRIPTION_PROJECT
            : SNIPPET_VISIBILITY_PRIVATE_DESCRIPTION_PERSONAL,
        },
        {
          value: '1',
          icon: 'shield',
          text: SNIPPET_VISIBILITY_INTERNAL_LABEL,
          description: SNIPPET_VISIBILITY_INTERNAL_DESCRIPTION,
        },
        {
          value: '2',
          icon: 'earth',
          text: SNIPPET_VISIBILITY_PUBLIC_LABEL,
          description: SNIPPET_VISIBILITY_PUBLIC_DESCRIPTION,
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
      <a v-if="helpLink" :href="helpLink" target="_blank"><gl-icon :size="12" name="question"/></a>
    </label>
    <gl-form-group id="visibility-level-setting">
      <gl-form-radio-group v-model="selected" stacked>
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
