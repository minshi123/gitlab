import IterationsList from 'ee/iterations/components/iterations_list.vue';
import { shallowMount } from '@vue/test-utils';

describe('Iterations list', () => {
  let wrapper;

  const mountComponent = (propsData = { iterations: [] }) => {
    wrapper = shallowMount(IterationsList, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('shows empty state', () => {
    mountComponent();

    expect(wrapper.html()).toHaveText('No iterations to show');
  });

  it('shows iteration', () => {
    const iteration = {
      id: '123',
      title: 'Iteration #1',
    };

    mountComponent({
      iterations: [iteration],
    });

    expect(wrapper.html()).not.toHaveText('No iterations to show');
    expect(wrapper.html()).toHaveText(iteration.title);
  });
});
