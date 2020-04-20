<script>
import { GlLink, GlSprintf, GlTab, GlTabs } from '@gitlab/ui';
import { s__ } from '~/locale';
import CodeInstruction from './code_instruction.vue';
import Tracking from '~/tracking';
import { TrackingActions, TrackingLabels } from '../constants';
import { trackInstallationTabChange } from '../utils';
import { mapGetters, mapState } from 'vuex';

export default {
  name: 'PyPiInstallation',
  components: {
    CodeInstruction,
    GlLink,
    GlSprintf,
    GlTab,
    GlTabs,
  },
  mixins: [
    Tracking.mixin({
      label: TrackingLabels.PYPI_INSTALLATION,
    }),
    trackInstallationTabChange,
  ],
  computed: {
    ...mapState(['pypiHelpPath']),
    ...mapGetters(['pypiPipCommand', 'pypiSetupCommand']),
  },
  i18n: {
    setupText: s__(
      `PackageRegistry|If you haven't already done so, you will need to add the below to your %{codeStart}.pypirc%{codeEnd} file.`,
    ),
    helpText: s__(
      'PackageRegistry|For more information on the PyPi registry, %{linkStart}see the documentation%{linkEnd}.',
    ),
  },
  trackingActions: { ...TrackingActions },
};
</script>

<template>
  <div class="append-bottom-default">
    <gl-tabs @input="trackInstallationTabChange">
      <gl-tab :title="s__('PackageRegistry|Installation')" title-item-class="js-installation-tab">
        <div class="prepend-left-default append-right-default">
          <p class="prepend-top-default font-weight-bold">
            {{ s__('PackageRegistry|Pip Command') }}
          </p>
          <code-instruction
            :instruction="pypiPipCommand"
            :copy-text="s__('PackageRegistry|Copy Pip command')"
            class="js-pip-command"
            :tracking-action="$options.trackingActions.COPY_PIP_INSTALL_COMMAND"
          />
        </div>
      </gl-tab>
      <gl-tab :title="s__('PackageRegistry|Registry Setup')" title-item-class="js-setup-tab">
        <div class="prepend-left-default append-right-default">
          <p>
            <gl-sprintf :message="$options.i18n.setupText">
              <template #code="{ content }">
                <code>{{ content }}</code>
              </template>
            </gl-sprintf>
          </p>
          <code-instruction
            :instruction="pypiSetupCommand"
            :copy-text="s__('PackageRegistry|Copy .pypirc content')"
            class="js-pypi-setup-content"
            multiline
            :tracking-action="$options.trackingActions.COPY_PYPI_SETUP_COMMAND"
          />
          <gl-sprintf :message="$options.i18n.helpText">
            <template #link="{ content }">
              <gl-link :href="pypiHelpPath" target="_blank">{{ content }}</gl-link>
            </template>
          </gl-sprintf>
        </div>
      </gl-tab>
    </gl-tabs>
  </div>
</template>
