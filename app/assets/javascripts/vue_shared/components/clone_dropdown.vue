<script>
import {
  GlNewDropdown,
  GlNewDropdownHeader,
  GlFormInputGroup,
  GlNewButton,
  GlIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __, sprintf } from '~/locale';

import { getBaseProtocol } from '~/lib/utils/url_utility';

const defaultLabel = __('Clone');
const labelProtocol = protocol =>
  sprintf(__('%{defaultLabel} with %{protocol}'), { defaultLabel, protocol }, false);

export default {
  components: {
    GlNewDropdown,
    GlNewDropdownHeader,
    GlFormInputGroup,
    GlNewButton,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
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
  labels: {
    defaultLabel,
    ssh: labelProtocol('SSH'),
    http: labelProtocol(getBaseProtocol().toUpperCase()),
  },
  copyURLTooltip: __('Copy URL'),
};
</script>
<template>
  <gl-new-dropdown :text="$options.labels.defaultLabel" category="primary" variant="info">
    <div class="pb-2 mx-1">
      <gl-new-dropdown-header>{{ $options.labels.ssh }}</gl-new-dropdown-header>

      <div class="mx-3">
        <gl-form-input-group id="clone-snippet-ssh-url" :value="sshLink" readonly select-on-click>
          <template #append>
            <gl-new-button
              v-gl-tooltip.hover
              :title="$options.copyURLTooltip"
              data-clipboard-target="#clone-snippet-ssh-url"
            >
              <gl-icon name="copy-to-clipboard" :title="__('Copy')" />
            </gl-new-button>
          </template>
        </gl-form-input-group>
      </div>

      <gl-new-dropdown-header>{{ $options.labels.http }}</gl-new-dropdown-header>

      <div class="mx-3">
        <gl-form-input-group id="clone-snippet-http-url" :value="httpLink" readonly select-on-click>
          <template #append>
            <gl-new-button
              v-gl-tooltip.hover
              :title="$options.copyURLTooltip"
              data-clipboard-target="#clone-snippet-http-url"
            >
              <gl-icon name="copy-to-clipboard" :title="__('Copy')" />
            </gl-new-button>
          </template>
        </gl-form-input-group>
      </div>
    </div>
  </gl-new-dropdown>
</template>
