import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import SettingsTabs from './components/incidents_settings_tabs.vue';

export default () => {
  const el = document.querySelector('.js-incidents-settings');

  if (!el) {
    return null;
  }

  const {
    dataset: {operationsSettingsEndpoint, templates, createIssue, issueTemplateKey, sendEmail},
  } = el;

  return new Vue({
    el,
    render(createElement) {
      return createElement(SettingsTabs, {
        props: {
          operationsSettingsEndpoint,
          alertSettings: {
            templates: JSON.parse(templates),
            createIssue: parseBoolean(createIssue),
            issueTemplateKey,
            sendEmail: parseBoolean(sendEmail),
          }
        },
      });
    },
  });
};
