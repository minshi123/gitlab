<script>
import { GlFormInput, GlFormGroup } from '@gitlab/ui';

export default {
  components: {
    GlFormInput,
    GlFormGroup,
  },
};
</script>
<template>
  <gl-form-group :label="__('Title')" label-for="title-field-edit">
    <gl-form-input data-qa-selector="snippet_title" v-bind="$attrs" v-on="$listeners" />
  </gl-form-group>
</template>
