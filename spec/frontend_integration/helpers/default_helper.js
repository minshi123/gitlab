import axios from '~/lib/utils/axios_utils';
import waitForPromises from 'helpers/wait_for_promises';

const TEST_API_VERSION = 'v4';
const TEST_RELATIVE_URL_ROOT = '/';

const useDefaultHelper = () => {
  let originalGon;

  return {
    setup() {
      window.gon = {
        ...(window.gon || {}),
        api_version: TEST_API_VERSION,
        relative_url_root: '',
      };
    },

    destroy() {
      window.gon = originalGon;
    },

    waitForAxios() {
      return axios.waitForAll().then(waitForPromises);
    },

    get apiVersion() {
      return TEST_API_VERSION;
    },

    get relativeUrlRoot() {
      return TEST_RELATIVE_URL_ROOT;
    },
  };
};

export default useDefaultHelper;
