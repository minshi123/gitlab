<script>
import { GlFormGroup, GlFormInput, GlDeprecatedButton } from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { __ } from '~/locale';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlDeprecatedButton,
  },
  props: {
    requirement: {
      type: Object,
      required: false,
      default: null,
    },
    requirementRequestActive: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      title: this.requirement?.title || '',
    };
  },
  computed: {
    saveButtonLabel() {
      return isEmpty(this.requirement) ? __('Create requirement') : __('Save changes');
    },
    disableSaveButton() {
      return this.title === '' || this.requirementRequestActive;
    },
  },
};
</script>

<template>
  <div class="requirement-form p-3">
    <gl-form-group :label="__('Requirement')" label-for="requirementTitle">
      <gl-form-input
        id="requirementTitle"
        v-model.trim="title"
        autofocus
        :disable="requirementRequestActive"
        :placeholder="__('Describe the requirement here')"
        @keyup.enter.exact="$emit('save', title)"
        @keyup.escape.exact="$emit('cancel')"
      />
    </gl-form-group>
    <div class="d-flex requirement-form-actions">
      <gl-deprecated-button
        :disabled="disableSaveButton"
        :loading="requirementRequestActive"
        category="primary"
        variant="success"
        class="mr-auto js-requirement-save"
        @click="$emit('save', title)"
        >{{ saveButtonLabel }}</gl-deprecated-button
      >
      <gl-deprecated-button class="js-requirement-cancel" @click="$emit('cancel')">{{
        __('Cancel')
      }}</gl-deprecated-button>
    </div>
  </div>
</template>
