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
      isCreate: isEmpty(this.requirement),
      title: this.requirement?.title || '',
    };
  },
  computed: {
    saveButtonLabel() {
      return this.isCreate ? __('Create requirement') : __('Save changes');
    },
    disableSaveButton() {
      return this.title === '' || this.requirementRequestActive;
    },
  },
  methods: {
    handleSave() {
      if (this.isCreate) {
        this.$emit('save', this.title);
      } else {
        this.$emit('save', {
          iid: this.requirement.iid,
          title: this.title,
        });
      }
    },
  },
};
</script>

<template>
  <div class="requirement-form" :class="{ 'p-3': isCreate }">
    <gl-form-group :label="__('Requirement')" label-for="requirementTitle">
      <gl-form-input
        id="requirementTitle"
        v-model.trim="title"
        autofocus
        :disabled="requirementRequestActive"
        :placeholder="__('Describe the requirement here')"
        @keyup.enter.exact="handleSave"
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
        @click="handleSave"
        >{{ saveButtonLabel }}</gl-deprecated-button
      >
      <gl-deprecated-button class="js-requirement-cancel" @click="$emit('cancel')">{{
        __('Cancel')
      }}</gl-deprecated-button>
    </div>
  </div>
</template>
