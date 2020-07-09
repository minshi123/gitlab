<script>
import {
  GlAlert,
  GlButton,
  GlSprintf,
  GlLink,
  GlIcon,
  GlFormGroup,
  GlFormInput,
  GlToggle,
} from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { I18N_PAGERDUTY_SETTINGS_FORM, CONFIGURE_PAGERDUTY_WEBHOOK_DOCS_LINK } from '../constants';

export default {
  components: {
    GlAlert,
    GlButton,
    GlSprintf,
    GlLink,
    GlIcon,
    GlFormGroup,
    GlFormInput,
    GlToggle,
    ClipboardButton,
  },
  inject: ['service', 'pagerDutySettings'],
  data() {
    return {
      active: this.pagerDutySettings.active,
      webhookUrl: this.pagerDutySettings.webhookUrl,
      webhookUpdateEndpoint: this.pagerDutySettings.webhookUpdateEndpoint,
      loading: false,
      resettingWebhook: false,
      showAlert: false,
      webhookUpdateFailed: false,
    };
  },
  i18n: I18N_PAGERDUTY_SETTINGS_FORM,
  CONFIGURE_PAGERDUTY_WEBHOOK_DOCS_LINK,
  computed: {
    formData() {
      return {
        enabled: this.enabled,
      };
    },
  },
  methods: {
    updatePagerDutyIntegrationSettings() {
      this.loading = true;

      this.service
        .updateSettings({
          endpoint: this.operationsSettingsEndpoint,
          settingsKey: 'pager_duty_setting_attributes',
          data: this.formData,
        })
        .catch(() => {
          this.loading = false;
        });
    },
    resetWebhookUrl() {
      this.resettingWebhook = true;
      this.service
        .resetWebhookUrl()
        .then(url => {
          this.showAlert = true;
          this.webhookUrl = url;
          this.webhookUpdateFailed = false;
        })
        .catch(() => {
          this.showAlert = true;
          this.webhookUpdateFailed = true;
        });
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="showAlert"
      :variant="webhookUpdateFailed ? 'danger' : 'success'"
      @dismiss="showAlert = false"
    >
      {{
        webhookUpdateFailed
          ? $options.i18n.webhookUrl.updateErrMsg
          : $options.i18n.webhookUrl.updateSuccessMsg
      }}
    </gl-alert>

    <p>{{ $options.i18n.introText }}</p>
    <form ref="settingsForm" @submit.prevent="updatePagerDutyIntegrationSettings">
      <gl-form-group class="col-8 col-md-9 gl-p-0">
        <gl-toggle
          id="active"
          v-model="active"
          :is-loading="loading"
          :label="$options.i18n.activeToggle.label"
        />
      </gl-form-group>

      <gl-form-group
        class="col-8 col-md-9 gl-p-0"
        :label="$options.i18n.webhookUrl.label"
        label-for="url"
        label-class="label-bold"
      >
        <div class="input-group">
          <gl-form-input id="url" :readonly="true" :value="webhookUrl" />
          <span class="input-group-append">
            <clipboard-button
              :text="webhookUrl"
              :title="$options.i18n.webhookUrl.copyToClipboard"
            />
          </span>
        </div>
        <div class="gl-text-gray-400 gl-pt-2">
          <gl-sprintf :message="$options.i18n.webhookUrl.helpText">
            <template #docsLink>
              <gl-link
                :href="$options.CONFIGURE_PAGERDUTY_WEBHOOK_DOCS_LINK"
                target="_blank"
                class="gl-display-inline-flex"
              >
                <span>{{ $options.i18n.webhookUrl.helpDocsLink }}</span>
                <gl-icon name="external-link" />
              </gl-link>
            </template>
          </gl-sprintf>
        </div>
        <gl-button class="gl-mt-3" data-testid="webhook-reset-btn" @click="resetWebhookUrl">{{
          $options.i18n.webhookUrl.resetWebhookUrl
        }}</gl-button>
      </gl-form-group>

      <gl-button
        ref="submitBtn"
        :disabled="loading"
        variant="success"
        type="submit"
        class="gl-mt-5 js-no-auto-disable"
      >
        {{ $options.i18n.saveBtnLabel }}
      </gl-button>
    </form>
  </div>
</template>
