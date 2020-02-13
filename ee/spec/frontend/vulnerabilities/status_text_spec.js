import { shallowMount } from '@vue/test-utils';
import StatusText from 'ee/vulnerabilities/components/status_text.vue';

describe('Vulnerability status text component', () => {
  let wrapper;

  const createWrapper = () => {
    // Create a dropdown that by default has the first vulnerability state selected.
    wrapper = shallowMount(StatusText, {
      propsData: {},
    });
  };

  beforeEach(createWrapper);
  afterEach(wrapper.destroy);

  it.ignore('shows the correct string given the vulnerability status', () => {});

  it.ignore(
    'shows the pipeline url when the vulnerability status is detected and there is a pipeline',
    () => {},
  );

  it.ignore('shows detected at with no URL if theres no pipeline', () => {});

  it.ignore('shows the skeleton loader when the state is loading', () => {});

  it.ignore('shows the component when the state is not loading', () => {});

  it.ignore('shows the user as loading when the user state is loading', () => {});

  it.ignore('loads the correct user after the AJAX call completes', () => {});

  it.ignore('will load a new user when the vulnerability is updated', () => {});

  it.ignore('shows an error if the user could not be retrieved', () => {});
});
