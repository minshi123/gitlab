import Vue from 'vue';
import { shallowMount } from '@vue/test-utils';
import emptyState from '~/environments/components/empty_state.vue';

describe('environments empty state', () => {
  const Component = Vue.extend(emptyState);
  let vm;

  afterEach(() => {
    vm.destroy();
  });

  describe('With permissions', () => {
    beforeEach(() => {
      vm = shallowMount(Component, {
        propsData: {
          newPath: 'foo',
          canCreateEnvironment: true,
          helpPath: 'bar',
        },
      });
    });

    it('renders empty state and new environment button', () => {
      expect(vm.find('.js-blank-state-title').text()).toEqual(
        "You don't have any environments right now",
      );

      expect(vm.find('.js-new-environment-button').attributes('href')).toEqual('foo');
    });
  });

  describe('Without permission', () => {
    beforeEach(() => {
      vm = shallowMount(Component, {
        propsData: {
          newPath: 'foo',
          canCreateEnvironment: false,
          helpPath: 'bar',
        },
      });
    });

    it('renders empty state without new button', () => {
      expect(vm.find('.js-blank-state-title').text()).toEqual(
        "You don't have any environments right now",
      );

      expect(vm.find('.js-new-environment-button').exists()).toBe(false);
    });
  });
});
