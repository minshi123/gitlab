import { shallowMount } from '@vue/test-utils';
import VulnerabilitiesApp from 'ee/vulnerabilities/components/vulnerabilities_app.vue';
import VulnerabilityList from 'ee/vulnerabilities/components/vulnerability_list.vue';
import { vulnerabilities } from './mock_data';

describe('Vulnerabilities app component', () => {
  let wrapper;

  const createWrapper = options => {
    return shallowMount(VulnerabilitiesApp, {
      propsData: {
        dashboardDocumentation: '#',
        emptyStateSvgPath: '#',
        projectFullPath: '#',
      },
      ...options,
    });
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when the vulnerabilties are loading', () => {
    beforeEach(() => {
      const $apollo = {
        queries: {
          vulnerabilities: [],
        },
      };

      createWrapper({ mocks: { $apollo } });
    });

    it('should be in the loading state', () => {
      expect(wrapper.find(VulnerabilityList).props().isLoading).toBe(true);
    });
  });

  describe('with some vulnerabilities', () => {
    beforeEach(() => {
      const $apollo = {
        queries: {
          vulnerabilities,
        },
      };

      // TODO: Is this the right way to mock? It seems wrong
      createWrapper({ mocks: { $apollo } });
    });

    it('should not be in the loading state', () => {
      expect(wrapper.find(VulnerabilityList).props().isLoading).toBe(false);
    });

    it('should pass the vulnerabilties to the vulnerabilites list', () => {
      const vulnerabilityList = wrapper.find(VulnerabilityList);

      expect(vulnerabilityList.props().vulnerabilities).toEqual(vulnerabilities);
    });
  });
});
