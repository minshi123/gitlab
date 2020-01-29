import { mount } from '@vue/test-utils';
import GeoNodeFormSelectiveSync from 'ee/geo_node_form/components/geo_node_form_selective_sync.vue';
import GeoNodeFormShards from 'ee/geo_node_form/components/geo_node_form_shards.vue';
import { MOCK_NODE, MOCK_SELECTIVE_SYNC_TYPES, MOCK_SYNC_SHARDS } from '../mock_data';

describe('GeoNodeFormSelectiveSync', () => {
  let wrapper;

  const propsData = {
    nodeData: MOCK_NODE,
    selectiveSyncTypes: MOCK_SELECTIVE_SYNC_TYPES,
    syncShardsOptions: MOCK_SYNC_SHARDS,
  };

  const createComponent = () => {
    wrapper = mount(GeoNodeFormSelectiveSync, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoNodeFormSyncContainer = () =>
    wrapper.find('.geo-node-form-selective-sync-container');
  const findGeoNodeFormSyncTypeField = () =>
    findGeoNodeFormSyncContainer().find('#node-selective-synchronization-field');
  const findGeoNodeFormShardsField = () => findGeoNodeFormSyncContainer().find(GeoNodeFormShards);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders Geo Node Form Sync Container', () => {
      expect(findGeoNodeFormSyncContainer().exists()).toBe(true);
    });

    it('renders Geo Node Sync Type Field', () => {
      expect(findGeoNodeFormSyncTypeField().exists()).toBe(true);
    });

    describe.each`
      syncType                        | showShards
      ${MOCK_SELECTIVE_SYNC_TYPES[0]} | ${false}
      ${MOCK_SELECTIVE_SYNC_TYPES[1]} | ${false}
      ${MOCK_SELECTIVE_SYNC_TYPES[2]} | ${true}
    `(`sync type`, ({ syncType, showShards }) => {
      beforeEach(() => {
        propsData.nodeData.selectiveSyncType = syncType.value;
        createComponent();
      });

      it(`${showShards ? 'show' : 'hide'} Shards Field`, () => {
        expect(findGeoNodeFormShardsField().exists()).toBe(showShards);
      });
    });
  });

  describe('methods', () => {
    describe('addSyncOption', () => {
      beforeEach(() => {
        createComponent();
      });

      it('should add value to nodeData', () => {
        expect(propsData.nodeData.selectiveSyncShards).toEqual([]);
        wrapper.vm.addSyncOption({ key: 'selectiveSyncShards', value: MOCK_SYNC_SHARDS[0].value });
        expect(propsData.nodeData.selectiveSyncShards).toEqual([MOCK_SYNC_SHARDS[0].value]);
      });
    });

    describe('removeSyncOption', () => {
      beforeEach(() => {
        propsData.nodeData.selectiveSyncShards = [MOCK_SYNC_SHARDS[0].value];
        createComponent();
      });

      it('should remove value from nodeData', () => {
        expect(propsData.nodeData.selectiveSyncShards).toEqual([MOCK_SYNC_SHARDS[0].value]);
        wrapper.vm.removeSyncOption({ key: 'selectiveSyncShards', index: 0 });
        expect(propsData.nodeData.selectiveSyncShards).toEqual([]);
      });
    });
  });
});
