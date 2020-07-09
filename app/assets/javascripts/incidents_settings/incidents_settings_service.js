import axios from '~/lib/utils/axios_utils';
import { refreshCurrentPage } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import { ERROR_MSG } from './constants';

export default class IncidentsSettingsService {
  constructor(settingsEndpoint, webhookUpdateEndpoint) {
    this.settingsEndpoint = settingsEndpoint;
    this.webhookUpdateEndpoint = webhookUpdateEndpoint;
  }

  updateSettings({ settingsKey, data }) {
    return axios
      .patch(this.settingsEndpoint, {
        project: {
          [settingsKey]: data,
        },
      })
      .then(() => {
        refreshCurrentPage();
      })
      .catch(({ response }) => {
        const message = response?.data?.message || '';

        createFlash(`${ERROR_MSG} ${message}`, 'alert');
      });
  }

  resetWebhookUrl() {
    return axios.post(this.webhookUpdateEndpoint);
  }
}
