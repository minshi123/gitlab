import { shallowMount } from '@vue/test-utils';
import StatusText from 'ee/vulnerabilities/components/status_text.vue';

describe('Vulnerability status text component', () => {
  let wrapper;

  const createWrapper = () => {
    wrapper = shallowMount(StatusText, {
      propsData: {},
    });
  };

  const message = () => wrapper.find({ ref: 'message' })

  beforeEach(createWrapper);
  afterEach(wrapper.destroy);

  //   <status-text
  //   class="mx-2"
  //   :vulnerability="vulnerability"
  //   :pipeline="pipeline"
  //   :pipeline-url="pipelineUrl"
  //   :is-loading="isLoadingVulnerability"
  // />

  it.ignore('shows the correct string given the vulnerability status', () => {
    const vulnerability = {
      state: 'detected'
    }

    wrapper.setProps({ vulnerability })

    expect(message.text()).stringContaining('Detected');
  });

  it.ignore(
    'shows the pipeline url when the vulnerability status is detected and there is a pipeline',
    () => { },
  );

  it.ignore('shows detected at with no URL if theres no pipeline', () => { });

  it.ignore('shows the skeleton loader when the state is loading', () => { });

  it.ignore('shows the component when the state is not loading', () => { });

  it.ignore('shows the user as loading when the user state is loading', () => { });

  it.ignore('loads the correct user after the AJAX call completes', () => { });

  it.ignore('will load a new user when the vulnerability is updated', () => { });

  it.ignore('shows an error if the user could not be retrieved', () => { });
});
