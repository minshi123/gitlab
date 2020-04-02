<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import { GlAlert, GlSprintf, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';

import { FETCH_SETTINGS_ERROR_MESSAGE } from '../../shared/constants';

import SettingsForm from './settings_form.vue';

export default {
  components: {
    SettingsForm,
    GlAlert,
    GlSprintf,
    GlLink,
  },
  i18n: {
    unavailableFeatureIntroText: s__(
      `ContainerRegistry|Currently, the Container Registry tag expiration feature is disabled for projects created before GitLab version 12.8.`,
    ),
    unavailableUserFeatureText: s__(
      `ContainerRegistry|For updates and more information, visit Issue %{linkStart}#196124%{linkEnd} or ask an admin to enabled it in the instance settings panel`,
    ),
    unavailableAdminFeatureText: s__(
      `ContainerRegistry|Visit the %{linkStart}administration page%{linkEnd} to enable it`,
    ),
    fetchSettingsErrorText: FETCH_SETTINGS_ERROR_MESSAGE,
  },
  data() {
    return {
      fetchSettingsError: false,
    };
  },
  computed: {
    ...mapState(['isAdmin', 'adminSettingsPath']),
    ...mapGetters({ isDisabled: 'getIsDisabled' }),
    showSettingForm() {
      return !this.isDisabled && !this.fetchSettingsError;
    },
    unavailableFeatureMessage() {
      const message = this.isAdmin
        ? this.$options.i18n.unavailableAdminFeatureText
        : this.$options.i18n.unavailableUserFeatureText;
      const link = this.isAdmin
        ? this.adminSettingsPath
        : 'https://gitlab.com/gitlab-org/gitlab/issues/196124';
      return { message, link };
    },
  },
  mounted() {
    this.fetchSettings().catch(() => {
      this.fetchSettingsError = true;
    });
  },
  methods: {
    ...mapActions(['fetchSettings']),
  },
};
</script>

<template>
  <div>
    <p>
      {{ s__('ContainerRegistry|Tag expiration policy is designed to:') }}
    </p>
    <ul>
      <li>{{ s__('ContainerRegistry|Keep and protect the images that matter most.') }}</li>
      <li>
        {{
          s__(
            "ContainerRegistry|Automatically remove extra images that aren't designed to be kept.",
          )
        }}
      </li>
    </ul>
    <settings-form v-if="showSettingForm" />
    <template v-else>
      <gl-alert v-if="isDisabled" :dismissible="false">
        <p>
          {{ $options.i18n.unavailableFeatureIntroText }}
          <gl-sprintf :message="unavailableFeatureMessage.message">
            <template #link="{content}">
              <gl-link :href="unavailableFeatureMessage.link" target="_blank">
                {{ content }}
              </gl-link>
            </template>
          </gl-sprintf>
        </p>
      </gl-alert>
      <gl-alert v-else-if="fetchSettingsError" variant="warning" :dismissible="false">
        <gl-sprintf :message="$options.i18n.fetchSettingsErrorText" />
      </gl-alert>
    </template>
  </div>
</template>
