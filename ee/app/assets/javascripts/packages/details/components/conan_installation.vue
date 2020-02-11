<script>
import { GlTab, GlTabs } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import CodeInstruction from './code_instruction.vue';
import Tracking from '~/tracking';
import { TrackingActions, TrackingLabels } from '../constants';
import { trackInstallationTabChange } from '../utils';
import { mapGetters, mapState } from 'vuex';

export default {
  name: 'ConanInstallation',
  components: {
    CodeInstruction,
    GlTab,
    GlTabs,
  },
  mixins: [
    Tracking.mixin({
      label: TrackingLabels.CONAN_INSTALLATION,
    }),
    trackInstallationTabChange,
  ],
  computed: {
    ...mapState(['conanHelpPath']),
    ...mapGetters(['conanInstallationCommand', 'conanSetupCommand']),
    helpText() {
      return sprintf(
        s__(
          `PackageRegistry|For more information on the Conan registry, %{linkStart}see the documentation%{linkEnd}.`,
        ),
        {
          linkStart: `<a href="${this.conanHelpPath}" target="_blank" rel="noopener noreferer">`,
          linkEnd: '</a>',
        },
        false,
      );
    },
  },
  trackingActions: { ...TrackingActions },
};
</script>

<template>
  <div class="append-bottom-default">
    <gl-tabs @input="trackInstallationTabChange">
      <gl-tab :title="s__('PackageRegistry|Installation')" title-item-class="js-installation-tab">
        <div class="prepend-left-default append-right-default">
          <p class="prepend-top-8 font-weight-bold">{{ s__('PackageRegistry|Conan Command') }}</p>
          <code-instruction
            :instruction="conanInstallationCommand"
            :copy-text="s__('PackageRegistry|Copy Conan Command')"
            class="js-conan-command"
            :tracking-action="$options.trackingActions.COPY_CONAN_COMMAND"
          />
        </div>
      </gl-tab>
      <gl-tab :title="s__('PackageRegistry|Registry Setup')" title-item-class="js-setup-tab">
        <div class="prepend-left-default append-right-default">
          <p class="prepend-top-8 font-weight-bold">
            {{ s__('PackageRegistry|Add Conan Remote') }}
          </p>
          <code-instruction
            :instruction="conanSetupCommand"
            :copy-text="s__('PackageRegistry|Copy Conan Setup Command')"
            class="js-conan-setup"
            :tracking-action="$options.trackingActions.COPY_CONAN_SETUP_COMMAND"
          />
          <p v-html="helpText"></p>
        </div>
      </gl-tab>
    </gl-tabs>
  </div>
</template>
