import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import ErrorTrackingActions from '~/error_tracking/components/error_tracking_actions.vue';

describe('Error Tracking Actions', () => {
  let wrapper;

  function mountComponent() {
    wrapper = shallowMount(ErrorTrackingActions, {
      propsData: {
        error: {
          id: '1',
          title: 'PG::ConnectionBad: FATAL',
          type: 'error',
          userCount: 0,
          count: '52',
          firstSeen: '2019-05-30T07:21:46Z',
          lastSeen: '2019-11-06T03:21:39Z',
          status: 'unresolved',
        },
      },
      stubs: { GlButton },
    });
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  const findButtons = () => wrapper.findAll(GlButton);

  it('renders the correct buttons when the error status is unresolved', () => {
    expect(findButtons().exists()).toBe(true);

    return wrapper.vm.$nextTick().then(() => {
      expect(
        findButtons()
          .at(0)
          .attributes('title'),
      ).toBe('Ignore');
      expect(
        findButtons()
          .at(1)
          .attributes('title'),
      ).toEqual('Resolve');
    });
  });

  it('renders the correct button when the error status is ignored', () => {
    wrapper.setProps({ error: { status: 'ignored' } });
    expect(findButtons().exists()).toBe(true);

    return wrapper.vm.$nextTick().then(() => {
      expect(
        findButtons()
          .at(0)
          .attributes('title'),
      ).toEqual('Undo Ignore');
    });
  });

  it('renders the correct button when the error status is resolved', () => {
    wrapper.setProps({ error: { status: 'resolved' } });
    expect(findButtons().exists()).toBe(true);

    return wrapper.vm.$nextTick().then(() => {
      expect(
        findButtons()
          .at(1)
          .attributes('title'),
      ).toEqual('Unresolve');
    });
  });
});
