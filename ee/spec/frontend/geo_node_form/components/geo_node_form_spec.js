import { shallowMount } from '@vue/test-utils';
import { visitUrl } from '~/lib/utils/url_utility';
import GeoNodeForm from 'ee/geo_node_form/components/geo_node_form.vue';
import GeoNodeFormCore from 'ee/geo_node_form/components/geo_node_form_core.vue';
import GeoNodeFormCapacities from 'ee/geo_node_form/components/geo_node_form_capacities.vue';
import { MOCK_NODE } from '../mock_data';

jest.mock('~/lib/utils/url_utility', () => ({
  visitUrl: jest.fn().mockName('visitUrlMock'),
}));

describe('GeoNodeForm', () => {
  let wrapper;

  const propsData = {
    node: MOCK_NODE,
  };

  const createComponent = () => {
    wrapper = shallowMount(GeoNodeForm, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoNodeFormContainer = () => wrapper.find('form');
  const findGeoNodeFormCoreField = () => findGeoNodeFormContainer().find(GeoNodeFormCore);
  const findGeoNodePrimaryField = () => findGeoNodeFormContainer().find('#node-primary-field');
  const findGeoNodeInternalUrlField = () =>
    findGeoNodeFormContainer().find('#node-internal-url-field');
  const findGeoNodeFormCapacitiesField = () =>
    findGeoNodeFormContainer().find(GeoNodeFormCapacities);
  const findGeoNodeObjectStorageField = () =>
    findGeoNodeFormContainer().find('#node-object-storage-field');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders Geo Node Form Container', () => {
      expect(findGeoNodeFormContainer().exists()).toBe(true);
    });

    describe.each`
      primaryNode | showCore | showPrimary | showInternalUrl | showCapacities | showObjectStorage
      ${true}     | ${true}  | ${true}     | ${true}         | ${true}        | ${false}
      ${false}    | ${true}  | ${true}     | ${false}        | ${true}        | ${true}
    `(
      `conditional fields`,
      ({
        primaryNode,
        showCore,
        showPrimary,
        showInternalUrl,
        showCapacities,
        showObjectStorage,
      }) => {
        beforeEach(() => {
          wrapper.vm.nodeData.primary = primaryNode;
        });

        it(`${showCore ? 'show' : 'hide'} Core Field`, () => {
          expect(findGeoNodeFormCoreField().exists()).toBe(showCore);
        });

        it(`${showPrimary ? 'show' : 'hide'} Primary Field`, () => {
          expect(findGeoNodePrimaryField().exists()).toBe(showPrimary);
        });

        it(`${showInternalUrl ? 'show' : 'hide'} Internal URL Field`, () => {
          expect(findGeoNodeInternalUrlField().exists()).toBe(showInternalUrl);
        });

        it(`${showCapacities ? 'show' : 'hide'} Capacities Field`, () => {
          expect(findGeoNodeFormCapacitiesField().exists()).toBe(showCapacities);
        });

        it(`${showObjectStorage ? 'show' : 'hide'} Object Storage Field`, () => {
          expect(findGeoNodeObjectStorageField().exists()).toBe(showObjectStorage);
        });
      },
    );
  });

  describe('methods', () => {
    describe('redirect', () => {
      beforeEach(() => {
        createComponent();
      });

      it('calls visitUrl', () => {
        wrapper.vm.redirect();
        expect(visitUrl).toHaveBeenCalled();
      });
    });
  });

  describe('created', () => {
    describe('when node prop exists', () => {
      beforeEach(() => {
        propsData.node = MOCK_NODE;
        createComponent();
      });

      it('sets nodeData to the prop.node', () => {
        expect(wrapper.vm.nodeData).toEqual(propsData.node);
      });
    });

    describe('when node prop does not exist', () => {
      beforeEach(() => {
        propsData.node = null;
        createComponent();
      });

      it('sets nodeData to the default node data', () => {
        expect(wrapper.vm.nodeData).not.toBeNull();
        expect(wrapper.vm.nodeData).not.toEqual(MOCK_NODE);
      });
    });
  });
});
