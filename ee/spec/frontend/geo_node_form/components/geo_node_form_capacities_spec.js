import { shallowMount } from '@vue/test-utils';
import GeoNodeFormCapacities from 'ee/geo_node_form/components/geo_node_form_capacities.vue';
import { MOCK_NODE } from '../mock_data';

describe('GeoNodeFormCapacities', () => {
  let wrapper;

  const propsData = {
    nodeData: MOCK_NODE,
  };

  const createComponent = () => {
    wrapper = shallowMount(GeoNodeFormCapacities, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoNodeFormCapacitiesContainer = () =>
    wrapper.find('.geo-node-form-capacities-container');
  const findGeoNodeFormRepositoryCapacityField = () =>
    findGeoNodeFormCapacitiesContainer().find('#node-repository-capacity-field');
  const findGeoNodeFormFileCapacityField = () =>
    findGeoNodeFormCapacitiesContainer().find('#node-file-capacity-field');
  const findGeoNodeFormVerificationCapacityField = () =>
    findGeoNodeFormCapacitiesContainer().find('#node-verification-capacity-field');
  const findGeoNodeFormContainerRepositoryCapacityField = () =>
    findGeoNodeFormCapacitiesContainer().find('#node-container-repository-capacity-field');
  const findGeoNodeFormReverificationIntervalField = () =>
    findGeoNodeFormCapacitiesContainer().find('#node-reverification-interval-field');

  describe('template', () => {
    it('renders Geo Node Form Capacities Container', () => {
      createComponent();
      expect(findGeoNodeFormCapacitiesContainer().exists()).toBe(true);
    });

    describe.each`
      primaryNode | showRepoCapacity | showFileCapacity | showVerificationCapacity | showContainerCapacity | showReverificationInterval
      ${true}     | ${false}         | ${false}         | ${true}                  | ${true}               | ${true}
      ${false}    | ${true}          | ${true}          | ${true}                  | ${true}               | ${false}
    `(
      `conditional fields`,
      ({
        primaryNode,
        showRepoCapacity,
        showFileCapacity,
        showVerificationCapacity,
        showContainerCapacity,
        showReverificationInterval,
      }) => {
        beforeEach(() => {
          propsData.nodeData.primary = primaryNode;
          createComponent();
        });

        it(`${showRepoCapacity ? 'show' : 'hide'} Repository Capacity Field`, () => {
          expect(findGeoNodeFormRepositoryCapacityField().exists()).toBe(showRepoCapacity);
        });

        it(`${showFileCapacity ? 'show' : 'hide'} File Capacity Field`, () => {
          expect(findGeoNodeFormFileCapacityField().exists()).toBe(showFileCapacity);
        });

        it(`${showVerificationCapacity ? 'show' : 'hide'} Verification Capacity Field`, () => {
          expect(findGeoNodeFormVerificationCapacityField().exists()).toBe(
            showVerificationCapacity,
          );
        });

        it(`${showContainerCapacity ? 'show' : 'hide'} Container Repository Capacity Field`, () => {
          expect(findGeoNodeFormContainerRepositoryCapacityField().exists()).toBe(
            showContainerCapacity,
          );
        });

        it(`${showReverificationInterval ? 'show' : 'hide'} Reverification Interval Field`, () => {
          expect(findGeoNodeFormReverificationIntervalField().exists()).toBe(
            showReverificationInterval,
          );
        });
      },
    );
  });
});
