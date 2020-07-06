<script>
  import {
    GlButton,
    GlSprintf,
    GlLink,
    GlIcon,
    GlFormGroup,
    GlFormCheckbox,
    GlNewDropdown,
    GlNewDropdownItem,
  } from '@gitlab/ui';
  import axios from '~/lib/utils/axios_utils';
  import { refreshCurrentPage } from '~/lib/utils/url_utility';
  import createFlash from '~/flash';
  import {__} from '~/locale';

  export default {
    props: {
      formSubmitEndpoint: {
        type: String,
        required: true,
      },
      settings: {
        type: Object,
        required: true,
        validator: ({templates, createIssue, issueTemplateKey, sendEmail}) => {
          return typeof issueTemplateKey === 'string'
            && Array.isArray(templates)
            && typeof createIssue === 'boolean'
            && typeof sendEmail === 'boolean';
        },
      },
      templates: {
        type: Array,
        required: false,
        default: () => [],
      }
    },
    data() {
      return {
        template: this.settings.templates,
        createIssueEnabled: this.settings.createIssue,
        issueTemplate: this.settings.issueTemplateKey,
        sendEmailEnabled: this.settings.sendEmail,
        loading: false,
        showFlashMessage: false,
      }
    },
    components: {
      GlButton,
      GlSprintf,
      GlLink,
      GlFormGroup,
      GlIcon,
      GlFormCheckbox,
      GlNewDropdown,
      GlNewDropdownItem,
    },
    i18n: {
      saveBtnLabel: __('Save changes'),
      introText: __('Action to take when receiving an alert. %{docsLink}'),
      introLinkText: __('More information.'),
      createIssue: {
        label: __('Create an issue. Issues are created for each alert triggered.'),
      },
      issueTemplate: {
        label: __('Issue template (optional)'),
      },
      sendEmail: {
        label: __('Send a separate email notification to Developers.'),
      }
    },
    computed: {
      issueTemplateHeader() {
        return this.issueTemplate || __('No template selected');
      },
    },
    methods: {
      updateAlertsIntegrationSettings() {
        this.loading = true;
        return axios
          .patch(this.formSubmitEndpoint, {
            project: {
              incident_setting_attributes: {
                ...this.getFormData()
              },
            },
          })
          .then(() => {
            refreshCurrentPage();
          })
          .catch(({response}) => {
            const message = response?.data?.message || '';

            createFlash(`${__('There was an error saving your changes.')} ${message}`, 'alert');
          })
          .finally((() => {
            this.loading = false;
          }))
      },
      getFormData() {
        return {
          create_issue: this.createIssueEnabled,
          issue_template_key: this.issueTemplate,
          send_email: this.sendEmailEnabled,
        }
      }
    }
  };
</script>

<template>
  <div>
    <!-- eslint-disable @gitlab/vue-require-i18n-attribute-strings -->
    <p>
      <gl-sprintf :message="$options.i18n.introText">
        <template #docsLink>
          <gl-link href="/help/user/project/integrations/prometheus#taking-action-on-incidents-ultimate"
                   target="_blank">
            <span>{{ $options.i18n.introLinkText }}</span>
          </gl-link>
        </template>
      </gl-sprintf>
    </p>
    <form ref="settingsForm" @submit.prevent="updateAlertsIntegrationSettings">
      <gl-form-group class="gl-pl-0">
        <gl-form-checkbox v-model="createIssueEnabled">
          <span>{{ $options.i18n.createIssue.label }}</span>
        </gl-form-checkbox>
      </gl-form-group>

      <gl-form-group
        label-size="sm"
        label-for="alert-integration-settings-issue-template"
        class="col-8 col-md-9 gl-px-5"
      >
        <label class="gl-display-inline-flex">
          {{$options.i18n.issueTemplate.label}}
          <gl-link href="/help/user/project/description_templates#creating-issue-templates" target="_blank">
            <gl-icon name="question" :size="12"/>
          </gl-link>
        </label>
        <gl-new-dropdown id="alert-integration-settings-issue-template"
                         :text="issueTemplateHeader" :block="true">
          <gl-new-dropdown-item v-for="issueTemplate in templates"
                                :is-check-item="true"
                                :is-checked="false">
            {{issueTemplate}}
          </gl-new-dropdown-item>

        </gl-new-dropdown>
      </gl-form-group>

      <gl-form-group class="gl-pl-0 mb-3">
        <gl-form-checkbox v-model="sendEmailEnabled">
          <span>{{ $options.i18n.sendEmail.label }}</span>
        </gl-form-checkbox>
      </gl-form-group>

      <gl-button
        ref="submitBtn"
        :disabled="loading"
        variant="success"
        type="submit"
        class="js-no-auto-disable"
      >
        {{ $options.i18n.saveBtnLabel }}
      </gl-button>
    </form>
  </div>
</template>
