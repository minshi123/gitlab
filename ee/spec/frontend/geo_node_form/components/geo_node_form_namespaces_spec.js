import { shallowMount } from '@vue/test-utils';
import { GlIcon, GlSearchBoxByType, GlDropdown } from '@gitlab/ui';
import Api from '~/api';
import flash from '~/flash';
import GeoNodeFormNamespaces from 'ee/geo_node_form/components/geo_node_form_namespaces.vue';
import { MOCK_SYNC_NAMESPACES } from '../mock_data';

jest.mock('~/flash');

describe('GeoNodeFormNamespaces', () => {
  let wrapper;

  const propsData = {
    selectedNamespaces: [],
  };

  const actionSpies = {
    searchNamespaces: jest.fn(),
    toggleNamespace: jest.fn(),
    isSelected: jest.fn(),
  };

  const createComponent = () => {
    wrapper = shallowMount(GeoNodeFormNamespaces, {
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
  const findGlDropdownSearch = () => findGlDropdown().find(GlSearchBoxByType);
  const findDropdownItems = () => findGlDropdown().findAll('li');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders GlDropdown', () => {
      expect(findGlDropdown().exists()).toBe(true);
    });

    it('renders findGlDropdownSearch', () => {
      expect(findGlDropdownSearch().exists()).toBe(true);
    });

    describe('findDropdownItems', () => {
      beforeEach(() => {
        delete actionSpies.isSelected;
        createComponent();
        wrapper.setProps({
          selectedNamespaces: [[MOCK_SYNC_NAMESPACES[0].id]],
        });
        wrapper.setData({
          synchronizationNamespaces: MOCK_SYNC_NAMESPACES,
        });
      });

      it('renders an instance for each namespace', () => {
        const dropdownItems = findDropdownItems();

        dropdownItems.wrappers.forEach((dI, index) => {
          expect(dI.html()).toContain(wrapper.vm.synchronizationNamespaces[index].name);
        });
      });

      it('hides GlIcon if namespace not in selectedNamespaces', () => {
        const dropdownItems = findDropdownItems();

        dropdownItems.wrappers.forEach((dI, index) => {
          const dropdownItemIcon = dI.find(GlIcon);

          expect(dropdownItemIcon.classes('invisible')).toBe(
            !wrapper.vm.isSelected(wrapper.vm.synchronizationNamespaces[index]),
          );
        });
      });
    });
  });

  describe('watchers', () => {
    describe('namespaceSearch', () => {
      beforeEach(() => {
        createComponent();
        wrapper.setData({
          namespaceSearch: 'test search',
        });
      });

      it(`should wait 500ms before calling searchNamespaces`, () => {
        expect(actionSpies.searchNamespaces).not.toHaveBeenCalledWith('test search');

        jest.runAllTimers(); // Debounce
        expect(actionSpies.searchNamespaces).toHaveBeenCalledWith('test search');
      });
    });
  });

  describe('methods', () => {
    describe('searchNamespaces', () => {
      beforeEach(() => {
        delete actionSpies.searchNamespaces;
        createComponent();
      });

      describe('on success', () => {
        beforeEach(() => {
          Api.groups = jest.fn(() => Promise.resolve(MOCK_SYNC_NAMESPACES));
          wrapper.vm.searchNamespaces();
        });

        it('should set call Api.groups', () => {
          expect(Api.groups).toHaveBeenCalled();
        });

        it('should set synchronizationNamespaces to response', () => {
          expect(wrapper.vm.synchronizationNamespaces).toBe(MOCK_SYNC_NAMESPACES);
        });
      });

      describe('on failure', () => {
        beforeEach(() => {
          Api.groups = jest.fn(() => Promise.reject());
          wrapper.vm.searchNamespaces();
        });

        it('should set call Api.groups', () => {
          expect(Api.groups).toHaveBeenCalled();
        });

        it('should call createFlash', () => {
          expect(flash).toHaveBeenCalledTimes(1);
          flash.mockClear();
        });
      });
    });

    describe('toggleNamespace', () => {
      beforeEach(() => {
        delete actionSpies.toggleNamespace;
      });

      describe('when namespace is in selectedNamespaces', () => {
        beforeEach(() => {
          createComponent();
          wrapper.setProps({
            selectedNamespaces: [MOCK_SYNC_NAMESPACES[0].id],
          });
        });

        it('emits `removeSyncOption`', () => {
          wrapper.vm.toggleNamespace(MOCK_SYNC_NAMESPACES[0]);
          expect(wrapper.emitted('removeSyncOption')).toBeTruthy();
        });
      });

      describe('when namespace is not in selectedNamespaces', () => {
        beforeEach(() => {
          createComponent();
          wrapper.setProps({
            selectedNamespaces: [MOCK_SYNC_NAMESPACES[0].id],
          });
        });

        it('emits `addSyncOption`', () => {
          wrapper.vm.toggleNamespace(MOCK_SYNC_NAMESPACES[1]);
          expect(wrapper.emitted('addSyncOption')).toBeTruthy();
        });
      });
    });

    describe('isSelected', () => {
      beforeEach(() => {
        delete actionSpies.isSelected;
      });

      describe('when namespace is in selectedNamespaces', () => {
        beforeEach(() => {
          createComponent();
          wrapper.setProps({
            selectedNamespaces: [MOCK_SYNC_NAMESPACES[0].id],
          });
        });

        it('returns `true`', () => {
          expect(wrapper.vm.isSelected(MOCK_SYNC_NAMESPACES[0])).toBeTruthy();
        });
      });

      describe('when namespace is not in selectedNamespaces', () => {
        beforeEach(() => {
          createComponent();
          wrapper.setProps({
            selectedNamespaces: [MOCK_SYNC_NAMESPACES[0].id],
          });
        });

        it('returns `false`', () => {
          expect(wrapper.vm.isSelected(MOCK_SYNC_NAMESPACES[1])).toBeFalsy();
        });
      });
    });

    describe('computed', () => {
      describe('dropdownTitle', () => {
        describe('when selectedNamespaces is empty', () => {
          beforeEach(() => {
            createComponent();
            wrapper.setProps({
              selectedNamespaces: [],
            });
          });

          it('returns `Select groups to replicate`', () => {
            expect(wrapper.vm.dropdownTitle).toBe('Select groups to replicate');
          });
        });

        describe('when selectedNamespaces is not empty', () => {
          beforeEach(() => {
            createComponent();
            wrapper.setProps({
              selectedNamespaces: [MOCK_SYNC_NAMESPACES[0].id],
            });
          });

          it('returns Groups selected: `this.selectedNamespaces.length`', () => {
            expect(wrapper.vm.dropdownTitle).toBe(
              `Groups selected: ${wrapper.vm.selectedNamespaces.length}`,
            );
          });
        });
      });

      describe('noSyncNamespaces', () => {
        describe('when synchronizationNamespaces.length > 0', () => {
          beforeEach(() => {
            createComponent();
            wrapper.setData({
              synchronizationNamespaces: MOCK_SYNC_NAMESPACES,
            });
          });

          it('returns `false`', () => {
            expect(wrapper.vm.noSyncNamespaces).toBeFalsy();
          });
        });
      });

      describe('when synchronizationNamespaces.length === 0', () => {
        beforeEach(() => {
          createComponent();
          wrapper.setData({
            synchronizationNamespaces: [],
          });
        });

        it('returns `true`', () => {
          expect(wrapper.vm.noSyncNamespaces).toBeTruthy();
        });
      });
    });
  });
});
