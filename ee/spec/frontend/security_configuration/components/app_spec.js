import { shallowMount } from '@vue/test-utils';
import { GlSprintf, GlTable } from '@gitlab/ui';
import SecurityConfigurationApp from 'ee/security_configuration/components/app.vue';

describe('Security Configuration App', () => {
  let wrapper;
  const createComponent = (props = {}) => {
    wrapper = shallowMount(SecurityConfigurationApp, {
      propsData: {
        features: [],
        autoDevopsEnabled: false,
        latestPipelinePath: 'http://latestPipelinePath',
        autoDevopsHelpPagePath: 'http://autoDevopsHelpPagePath',
        helpPagePath: 'http://helpPagePath',
        autoFixSettingsProps: {},
        ...props,
      },
      stubs: { GlSprintf },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const generateFeatures = n =>
    [...Array(n).keys()].map(i => ({
      name: `name-feature-${i}`,
      description: `description-feature-${i}`,
      link: `link-feature-${i}`,
    }));

  const getPipelinesLink = () => wrapper.find({ ref: 'pipelinesLink' });
  const getFeaturesTable = () => wrapper.find(GlTable);

  describe('header', () => {
    it.each`
      autoDevopsEnabled | expectedUrl
      ${true}           | ${'http://autoDevopsHelpPagePath'}
      ${false}          | ${'http://latestPipelinePath'}
    `(
      'displays a link to "$expectedUrl" when autoDevops is "$autoDevopsEnabled"',
      ({ autoDevopsEnabled, expectedUrl }) => {
        createComponent({ autoDevopsEnabled });

        expect(getPipelinesLink().attributes('href')).toBe(expectedUrl);
        expect(getPipelinesLink().attributes('target')).toBe('_blank');
      },
    );
  });

  describe('features table', () => {
    it('passes the expected data to the GlTable', () => {
      const features = generateFeatures(5);

      createComponent({ features });

      expect(getFeaturesTable().props('items')).toHaveLength(5);
      expect(getFeaturesTable().props('stacked')).toBe('md');
    });

    it('displays a given feature', () => {
      const features = generateFeatures(1);

      createComponent({ features });

      expect(getFeaturesTable().element).toMatchSnapshot();
    });

    it.each`
      configured | statusText
      ${true}    | ${'Enabled'}
      ${false}   | ${'Not yet enabled'}
    `(
      `displays "$statusText" if the given feature's configuration status is: "$configured"`,
      ({ configured, statusText }) => {
        createComponent();

        expect(wrapper.vm.getStatusText(configured)).toBe(statusText);
      },
    );
  });
});
