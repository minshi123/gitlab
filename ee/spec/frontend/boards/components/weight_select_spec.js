import { mount } from '@vue/test-utils';
import WeightSelect from 'ee/boards/components/weight_select.vue';
import { GlDropdown } from '@gitlab/ui';

describe('WeightSelect', () => {
  let wrapper;

  const valueContainer = () => wrapper.find('.value');
  const weightDropdown = () => wrapper.find(GlDropdown);
  const editButton = () => wrapper.find('button');

  const defaultProps = {
    weights: ['Any Weight', 'No Weight', 1, 2, 3],
    board: {
      weight: null,
    },
    canEdit: true,
  };
  
  const createComponent = (props = {}) => {
    wrapper = mount(WeightSelect, {
      propsData: {
        ...defaultProps,
        ...props,
      }
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when no weight has been selected', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays "Any Weight"', () => {
      expect(valueContainer().text()).toEqual('Any Weight');
    });

    it('hides the weight dropdown', () => {
      expect(weightDropdown().isVisible()).toBeFalsy();
    });
  });

  describe('when editing the weight', () => {
    beforeEach(() => {
      createComponent();
      editButton().trigger('click');
    });

    describe('and no weight has been selected yet', () => {
      it('hides the value text', () => {
        expect(valueContainer().isVisible()).toBeFalsy();
      });
  
      it('shows the weight dropdown', () => {
        expect(weightDropdown().isVisible()).toBeTruthy();
      });
    });

    describe('and a weight has been selected', () => {
      beforeEach(() => {
        wrapper.find('.js-weight-select').trigger('click');
      });
  
      it('shows the value text', () => {
        expect(valueContainer().isVisible()).toBeTruthy();
      });
  
      it('hides the weight dropdown', () => {
        expect(weightDropdown().isVisible()).toBeFalsy();
      });
    });  
  });
  
  describe('when a new weight is selected', () => {
    describe('and the weight is "Any Weight"', () => {
      beforeEach(() => {
        createComponent({ board: { weight: 'Any Weight' }});
      });

      it('displays "No Weight"', () => {
        expect(valueContainer().text()).toEqual('Any Weight');
      });
    });

    describe('and the value is "No Weight"', () => {
      beforeEach(() => {
        createComponent({ board: { weight: 'No Weight' }});
      });

      it('displays "No Weight"', () => {
        expect(valueContainer().text()).toEqual('No Weight');
      });
    });

    describe('and the value is 0', () => {
      beforeEach(() => {
        createComponent({ board: { weight: 0 }});
      });

      it('displays "No Weight"', () => {
        expect(valueContainer().text()).toEqual('No Weight');
      });
    });

    describe('and the value is -1', () => {
      beforeEach(() => {
        createComponent({ board: { weight: -1 }});
      });

      it('displays "Any Weight"', () => {
        expect(valueContainer().text()).toEqual('Any Weight');
      });
    });

    describe('and the value is 1', () => {
      beforeEach(() => {
        createComponent({ board: { weight: 1 }});
      });

      it('displays "1"', () => {
        expect(valueContainer().text()).toEqual('1');
      });
    });
  });

});
