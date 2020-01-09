import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import GeoNodeFormApp from 'ee/geo_node_form/components/app.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeFormApp', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(GeoNodeFormApp, {
      localVue,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoNodeFormContainer = () => wrapper.find('.geo-node-form-container');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the node form container', () => {
      expect(findGeoNodeFormContainer().exists()).toBe(true);
    });

    it('renders `Geo Node Form` header text', () => {
      expect(findGeoNodeFormContainer().text()).toContain('Geo Node Form');
    });
  });
});
