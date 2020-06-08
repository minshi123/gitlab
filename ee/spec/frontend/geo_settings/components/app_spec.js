import { shallowMount } from '@vue/test-utils';
import GeoSettingsApp from 'ee/geo_settings/components/app.vue';

describe('GeoSettingsApp', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(GeoSettingsApp);
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoSettingsContainer = () => wrapper.find('.geo-settings-container');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the settings container', () => {
      expect(findGeoSettingsContainer().exists()).toBe(true);
    });

    it('`Geo Settings Form` header text', () => {
      expect(findGeoSettingsContainer().text()).toContain('Geo Settings Form');
    });
  });
});
