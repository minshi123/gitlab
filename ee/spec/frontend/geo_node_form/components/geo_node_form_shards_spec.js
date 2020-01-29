import { mount } from '@vue/test-utils';
import { GlIcon, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import GeoNodeFormShards from 'ee/geo_node_form/components/geo_node_form_shards.vue';
import { MOCK_SYNC_SHARDS } from '../mock_data';

describe('GeoNodeFormShards', () => {
  let wrapper;

  const propsData = {
    selectedShards: [],
    syncShardsOptions: MOCK_SYNC_SHARDS,
  };

  const actionSpies = {
    toggleShard: jest.fn(),
    isSelected: jest.fn(),
  };

  const createComponent = () => {
    wrapper = mount(GeoNodeFormShards, {
      propsData,
      methods: {
        ...actionSpies,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGlDropdown = () => wrapper.find(GlDropdown);
  const findGlDropdownItem = () => findGlDropdown().findAll(GlDropdownItem);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders GlDropdown', () => {
      expect(findGlDropdown().exists()).toBe(true);
    });

    describe('GlDropdownItem', () => {
      beforeEach(() => {
        propsData.selectedShards = [MOCK_SYNC_SHARDS[0].value];
        delete actionSpies.isSelected;
        createComponent();
      });

      it('renders an instance for each shard', () => {
        const dropdownItems = findGlDropdownItem();

        for (let i = 0; i < dropdownItems.length; i += 1) {
          expect(dropdownItems.at(i).html()).toContain(wrapper.vm.syncShardsOptions[i].label);
        }
      });

      it('hides GlIcon if shard not in selectedShards', () => {
        const dropdownItems = findGlDropdownItem();

        for (let i = 0; i < dropdownItems.length; i += 1) {
          const dropdownItem = dropdownItems.at(i);
          const dropdownItemIcon = dropdownItem.find(GlIcon);

          if (wrapper.vm.isSelected(propsData.syncShardsOptions[i])) {
            expect(dropdownItemIcon.classes()).not.toContain('invisible');
          } else {
            expect(dropdownItemIcon.classes()).toContain('invisible');
          }
        }
      });
    });
  });

  describe('methods', () => {
    describe('toggleShard', () => {
      beforeEach(() => {
        delete actionSpies.toggleShard;
      });

      describe('when shard is in selectedShards', () => {
        beforeEach(() => {
          propsData.selectedShards = [MOCK_SYNC_SHARDS[0].value];
          createComponent();
        });

        it('emits `removeSyncOption`', () => {
          wrapper.vm.toggleShard(MOCK_SYNC_SHARDS[0]);
          expect(wrapper.emitted('removeSyncOption')).toBeTruthy();
        });
      });

      describe('when shard is not in selectedShards', () => {
        beforeEach(() => {
          propsData.selectedShards = [MOCK_SYNC_SHARDS[0].value];
          createComponent();
        });

        it('emits `addSyncOption`', () => {
          wrapper.vm.toggleShard(MOCK_SYNC_SHARDS[1]);
          expect(wrapper.emitted('addSyncOption')).toBeTruthy();
        });
      });
    });

    describe('isSelected', () => {
      beforeEach(() => {
        delete actionSpies.isSelected;
      });

      describe('when shard is in selectedShards', () => {
        beforeEach(() => {
          propsData.selectedShards = [MOCK_SYNC_SHARDS[0].value];
          createComponent();
        });

        it('returns `true`', () => {
          const res = wrapper.vm.isSelected(MOCK_SYNC_SHARDS[0]);
          expect(res).toBeTruthy();
        });
      });

      describe('when shard is not in selectedShards', () => {
        beforeEach(() => {
          propsData.selectedShards = [MOCK_SYNC_SHARDS[0].id];
          createComponent();
        });

        it('returns `false`', () => {
          const res = wrapper.vm.isSelected(MOCK_SYNC_SHARDS[1]);
          expect(res).toBeFalsy();
        });
      });
    });

    describe('computed', () => {
      describe('dropdownTitle', () => {
        describe('when selectedShards is empty', () => {
          beforeEach(() => {
            propsData.selectedShards = [];
            createComponent();
          });

          it('returns `Select shards to replicate`', () => {
            const res = wrapper.vm.dropdownTitle;
            expect(res).toBe('Select shards to replicate');
          });
        });

        describe('when selectedShards is not empty', () => {
          beforeEach(() => {
            propsData.selectedShards = [MOCK_SYNC_SHARDS[0].value];
            createComponent();
          });

          it('returns Shards selected: `this.selectedShards.length`', () => {
            const res = wrapper.vm.dropdownTitle;
            expect(res).toBe(`Shards selected: ${propsData.selectedShards.length}`);
          });
        });
      });
    });
  });
});
