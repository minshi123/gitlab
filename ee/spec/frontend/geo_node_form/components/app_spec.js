import { shallowMount } from '@vue/test-utils';
import GeoNodeFormApp from 'ee/geo_node_form/components/app.vue';
import GeoNodeForm from 'ee/geo_node_form/components/geo_node_form.vue';
import { MOCK_SELECTIVE_SYNC_TYPES, MOCK_SYNC_SHARDS } from '../mock_data';

describe('GeoNodeFormApp', () => {
  let wrapper;

  const propsData = {
    selectiveSyncTypes: MOCK_SELECTIVE_SYNC_TYPES,
    syncShardsOptions: MOCK_SYNC_SHARDS,
    node: undefined,
  };

  const createComponent = () => {
    wrapper = shallowMount(GeoNodeFormApp, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoNodeFormTitle = () => wrapper.find('.page-title');
  const findGeoNodeFormPill = () => wrapper.find('.rounded-pill');
  const findGeoForm = () => wrapper.find(GeoNodeForm);

  describe('render', () => {
    beforeEach(() => {
      createComponent();
    });

    describe.each`
      formType                     | node                  | title              | pillTitle      | pillClass
      ${'create a secondary node'} | ${null}               | ${'New Geo Node'}  | ${'Secondary'} | ${'bg-secondary-100'}
      ${'update a secondary node'} | ${{ primary: false }} | ${'Edit Geo Node'} | ${'Secondary'} | ${'bg-secondary-100'}
      ${'update a primary node'}   | ${{ primary: true }}  | ${'Edit Geo Node'} | ${'Primary'}   | ${'bg-primary-400 text-white'}
    `(`form header`, ({ formType, node, title, pillTitle, pillClass }) => {
      describe(`when node form is to ${formType}`, () => {
        beforeEach(() => {
          propsData.node = node;
          createComponent();
        });

        it(`sets the node form title to ${title}`, () => {
          expect(findGeoNodeFormTitle().text()).toBe(title);
        });

        it(`sets the node form pill title to ${pillTitle}`, () => {
          expect(findGeoNodeFormPill().text()).toBe(pillTitle);
        });

        it(`sets the node form pill classes to contain ${pillClass}`, () => {
          expect(
            findGeoNodeFormPill()
              .classes()
              .join(' '),
          ).toContain(pillClass);
        });
      });
    });

    it('the Geo Node Form', () => {
      expect(findGeoForm().exists()).toBe(true);
    });
  });
});
