import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import IssuePlaceholderNote from '~/vue_shared/components/notes/placeholder_note.vue';
import { userDataMock } from '../../../notes/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

const getters = {
  getUserData: () => userDataMock,
};

describe('Issue placeholder note component', () => {
  let wrapper;

  const createComponent = (isIndividual = false) => {
    wrapper = shallowMount(IssuePlaceholderNote, {
      localVue,
      store: new Vuex.Store({
        getters,
      }),
      propsData: {
        note: {
          body: 'Foo',
          individual_note: isIndividual,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('matches snapshot', () => {
    createComponent();

    expect(wrapper.element).toMatchSnapshot();
  });
});
