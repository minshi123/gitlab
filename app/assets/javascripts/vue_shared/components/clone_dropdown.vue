<script>
import {
  GlNewDropdown,
  GlNewDropdownHeader,
  GlFormInputGroup,
  GlNewButton,
  GlIcon,
} from '@gitlab/ui';
import { __, sprintf } from '~/locale';

import { getBaseProtocol } from '~/lib/utils/url_utility';

export default {
  components: {
    GlNewDropdown,
    GlNewDropdownHeader,
    GlFormInputGroup,
    GlNewButton,
    GlIcon,
  },
  props: {
    sshLink: {
      type: String,
      required: true,
    },
    httpLink: {
      type: String,
      required: true,
    },
  },
  computed: {
    cloneLabel() {
      return __('Clone');
    },
    cloneSSHLabel() {
      return sprintf(__('%{label} with SSH'), { label: this.cloneLabel }, false);
    },
    cloneHTTPLabel() {
      return sprintf(
        __('%{label} with %{protocol}'),
        { label: this.cloneLabel, protocol: getBaseProtocol().toUpperCase() },
        false,
      );
    },
  },
};
</script>
<template>
  <gl-new-dropdown :text="cloneLabel" category="primary" variant="info">
    <div class="pb-2 mx-1">
      <gl-new-dropdown-header>{{ cloneSSHLabel }}</gl-new-dropdown-header>

      <div class="mx-3">
        <gl-form-input-group id="clone-snippet-ssh-url" :value="sshLink" readonly select-on-click>
          <template #append>
            <gl-new-button data-clipboard-target="#clone-snippet-ssh-url">
              <gl-icon name="copy-to-clipboard" :title="__('Copy')" />
            </gl-new-button>
          </template>
        </gl-form-input-group>
      </div>

      <gl-new-dropdown-header>{{ cloneHTTPLabel }}</gl-new-dropdown-header>

      <div class="mx-3">
        <gl-form-input-group id="clone-snippet-http-url" :value="httpLink" readonly select-on-click>
          <template #append>
            <gl-new-button data-clipboard-target="#clone-snippet-http-url">
              <gl-icon name="copy-to-clipboard" :title="__('Copy')" />
            </gl-new-button>
          </template>
        </gl-form-input-group>
      </div>
    </div>
  </gl-new-dropdown>
</template>
