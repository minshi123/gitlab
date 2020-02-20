import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import GkeZoneDropdown from '~/create_cluster/gke_cluster/components/gke_zone_dropdown.vue';
import DropdownHiddenInput from '~/vue_shared/components/dropdown/dropdown_hidden_input.vue';
import { createStore } from '~/create_cluster/gke_cluster/store';
import {
  SET_PROJECT,
  SET_ZONES,
  SET_PROJECT_BILLING_STATUS,
} from '~/create_cluster/gke_cluster/store/mutation_types';
import { selectedZoneMock, selectedProjectMock, gapiZonesResponseMock } from '../mock_data';

const localVue = createLocalVue();

localVue.use(Vuex);

const propsData = {
  fieldId: 'cluster_provider_gcp_attributes_gcp_zone',
  fieldName: 'cluster[provider_gcp_attributes][gcp_zone]',
};

const LABELS = {
  LOADING: 'Fetching zones',
  DISABLED: 'Select project to choose zone',
  DEFAULT: 'Select zone',
};

describe('GkeZoneDropdown', () => {
  let store;
  let wrapper;

  beforeEach(() => {
    store = createStore();
    wrapper = shallowMount(GkeZoneDropdown, { propsData, store, localVue });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('toggleText', () => {
    it('returns disabled state toggle text', () => {
      expect(wrapper.vm.toggleText).toBe(LABELS.DISABLED);
    });

    it('returns loading toggle text', () => {
      wrapper.setData({ isLoading: true });
      expect(wrapper.vm.toggleText).toBe(LABELS.LOADING);
    });

    it('returns default toggle text', () => {
      expect(wrapper.vm.toggleText).toBe(LABELS.DISABLED);

      wrapper.vm.$store.commit(SET_PROJECT, selectedProjectMock);
      wrapper.vm.$store.commit(SET_PROJECT_BILLING_STATUS, true);

      expect(wrapper.vm.toggleText).toBe(LABELS.DEFAULT);
    });

    it('returns project name if project selected', () => {
      wrapper.vm.setItem(selectedZoneMock);
      expect(wrapper.vm.toggleText).toBe(selectedZoneMock);
    });
  });

  describe('selectItem', () => {
    beforeEach(() => {
      wrapper.vm.$store.commit(SET_ZONES, gapiZonesResponseMock.items);
      return wrapper.vm.$nextTick();
    });

    it('reflects new value when dropdown item is clicked', done => {
      const dropdown = wrapper.find(DropdownHiddenInput);

      expect(dropdown.attributes('value')).toEqual('');

      wrapper.find('.dropdown-content button').trigger('click');
      wrapper.vm
        .$nextTick()
        .then(() => {
          expect(dropdown.attributes('value')).toEqual(selectedZoneMock);
          done();
        })
        .catch(done.fail);
    });
  });
});
