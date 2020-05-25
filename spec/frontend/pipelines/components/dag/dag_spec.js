import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import waitForPromises from 'helpers/wait_for_promises';
import { GlAlert } from '@gitlab/ui';
import Dag from '~/pipelines/components/dag/dag.vue';
import { DEFAULT, PARSE_FAILURE, LOAD_FAILURE, UNSUPPORTED_DATA } from '~/pipelines/components/dag//constants';
import mockGraphData from './mock_data';

describe('Pipeline DAG graph wrapper', () => {
  let wrapper;
  let mock;
  const getAlert = () => wrapper.find(GlAlert);
  const getGraph = () => wrapper.find('[data-testid="dag-graph-container"]');
  const failureFn = () => wrapper.vm.reportFailure;
  const getErrorText = (type) => wrapper.vm.$options.errorTexts[type]

  const dataPath = '/root/test/pipelines/90/dag.json';

  const createComponent = (propsData = {}, method = mount) => {

    if (wrapper?.destroy) {
      wrapper.destroy();
    }

    wrapper = method(Dag, {
      propsData,
      data() {
        return {
          showFailureAlert: false,
        };
      },
    });
  };

  beforeEach(() =>  {
    mock = new MockAdapter(axios);
  })

  afterEach(() => {
    mock.restore();
    wrapper.destroy();
    wrapper = null;
  });

  describe('when there is no dataUrl', () => {
    beforeEach(() => {
      createComponent({ graphUrl: undefined });
    });

    it('shows the alert and not the graph', () => {
      expect(getAlert().exists()).toBe(true);
      expect(getAlert().text()).toBe(getErrorText(DEFAULT));
      expect(getGraph().exists()).toBe(false);
    });
  });

  describe('when there is a dataUrl', () => {

    describe('and the data fetch succeeds', () => {
      beforeEach(() => {
        mock.onGet(dataPath).reply(200, mockGraphData);
        createComponent({ graphUrl: dataPath });
      });

      it('shows the graph and not the alert', () => {

        return wrapper.vm
          .$nextTick()
          .then(waitForPromises)
          .then(() => {
            expect(getAlert().exists()).toBe(false);
            expect(getGraph().exists()).toBe(true);
          });
      });
    });

    describe('but the data fetch fails', () => {
      beforeEach(() => {
        mock.onGet(dataPath).replyOnce(500);
        createComponent({ graphUrl: dataPath });
      });

      it('shows the alert and not the graph', () => {
        return wrapper.vm
          .$nextTick()
          .then(waitForPromises)
          .then(() => {
            expect(getAlert().exists()).toBe(true);
            expect(getAlert().text()).toBe(getErrorText(LOAD_FAILURE));
            expect(getGraph().exists()).toBe(false);
          });
      });
    });
  });
});
