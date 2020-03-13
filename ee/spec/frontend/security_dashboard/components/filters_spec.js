import Filters from 'ee/security_dashboard/components/filters.vue';
import createStore from 'ee/security_dashboard/store';
import { mount } from '@vue/test-utils';

describe('Filter component', () => {
  let wrapper;
  const store = createStore();

  describe('severity', () => {
    beforeEach(() => {
      wrapper = mount(Filters, { store });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('should display all filters', () => {
      expect(wrapper.findAll('.js-filter').length).toEqual(3);
    });

    it('should display "Hide dismissed vulnerabilities" toggle', () => {
      expect(wrapper.findAll('.js-toggle').length).toEqual(1);
    });
  });
});
