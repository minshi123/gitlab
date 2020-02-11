<script>
import { GlTab, GlTabs } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import CodeInstruction from './code_instruction.vue';
import Tracking from '~/tracking';
import { TrackingActions, TrackingLabels } from '../constants';
import { trackInstallationTabChange } from '../utils';
import { mapGetters, mapState } from 'vuex';

export default {
  name: 'NugetInstallation',
  components: {
    CodeInstruction,
    GlTab,
    GlTabs,
  },
  mixins: [
    Tracking.mixin({
      label: TrackingLabels.NUGET_INSTALLATION,
    }),
    trackInstallationTabChange,
  ],
  computed: {
    ...mapState(['nugetPath']),
    ...mapGetters(['nugetInstallationCommand', 'nugetSetupCommand']),
    helpText() {
      return sprintf(
        s__(
          `PackageRegistry|For more information on the NuGet registry, %{linkStart}see the documentation%{linkEnd}.`,
        ),
        {
          linkStart: `<a href="${this.nugetPath}" target="_blank" rel="noopener noreferer">`,
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
          <p class="prepend-top-8 font-weight-bold">{{ s__('PackageRegistry|NuGet Command') }}</p>
          <code-instruction
            :instruction="nugetInstallationCommand"
            :copy-text="s__('PackageRegistry|Copy NuGet Command')"
            class="js-nuget-command"
            :tracking-action="$options.trackingActions.COPY_NUGET_INSTALL_COMMAND"
          />
        </div>
      </gl-tab>
      <gl-tab :title="s__('PackageRegistry|Registry Setup')" title-item-class="js-setup-tab">
        <div class="prepend-left-default append-right-default">
          <p class="prepend-top-8 font-weight-bold">
            {{ s__('PackageRegistry|Add NuGet Source') }}
          </p>
          <code-instruction
            :instruction="nugetSetupCommand"
            :copy-text="s__('PackageRegistry|Copy NuGet Setup Command')"
            class="js-nuget-setup"
            :tracking-action="$options.trackingActions.COPY_NUGET_SETUP_COMMAND"
          />
          <p v-html="helpText"></p>
        </div>
      </gl-tab>
    </gl-tabs>
  </div>
</template>
