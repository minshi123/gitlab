import createState from 'ee/security_dashboard/store/modules/filters/state';
import * as getters from 'ee/security_dashboard/store/modules/filters/getters';

describe('filters module getters', () => {
  const mockedGetters = state => {
    const getFilter = filterId => getters.getFilter(state)(filterId);

    return { getFilter };
  };
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('getFilter', () => {
    it('should return the type filter information', () => {
      const typeFilter = getters.getFilter(state)('report_type');

      expect(typeFilter.name).toEqual('Report type');
    });
  });

  describe('activeFilters', () => {
    it('should return no severity filters', () => {
      const activeFilters = getters.activeFilters(state, mockedGetters(state));

      expect(activeFilters.severity).toHaveLength(0);
    });

    it('should return multiple dummy filters"', () => {
      const dummyFilter = {
        id: 'dummy',
        options: [{ id: 'one' }, { id: 'two' }],
        selection: new Set(['one', 'two']),
      };
      state.filters.push(dummyFilter);
      const activeFilters = getters.activeFilters(state, mockedGetters(state));

      expect(activeFilters.dummy).toHaveLength(2);
    });
  });
});
