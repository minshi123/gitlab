import { shallowMount } from '@vue/test-utils';
import { GlModal } from '@gitlab/ui';
import Component from 'ee/feature_flags/components/configure_feature_flags_modal.vue';
import Callout from '~/vue_shared/components/callout.vue';

describe('Configure Feature Flags Modal', () => {
  const projectName = 'fakeProjectName';
  const mockEvent = { preventDefault: jest.fn() };
  let findGlModal;
  let findProjectNameInput;
  let wrapper;
  let propsData;

  afterEach(() => wrapper.destroy());

  beforeEach(() => {
    propsData = {
      helpPath: '/help/path',
      helpClientLibrariesPath: '/help/path/#flags',
      helpClientExamplePath: '/feature-flags#clientexample',
      apiUrl: '/api/url',
      instanceId: 'instance-id-token',
      isRotating: false,
      hasRotateError: false,
      canUserRotateToken: true,
    };

    wrapper = shallowMount(Component, {
      propsData,
      provide: {
        projectName,
      },
    });

    findGlModal = () => wrapper.find(GlModal);
    findProjectNameInput = () => wrapper.find('#project_name');
  });

  describe('actions', () => {
    it('should have Primary and Cancel actions', () => {
      expect(findGlModal().props('actionCancel').text).toBe('Close');
      expect(findGlModal().props('actionPrimary').text).toBe('Regenerate instance ID');
    });

    it('Primary action should be disabled if the user cannot rotate tokens', async () => {
      wrapper.setProps({ canUserRotateToken: false });
      wrapper.setData({ enteredProjectName: projectName });
      await wrapper.vm.$nextTick();
      const [{ disabled }] = findGlModal().props('actionPrimary').attributes;
      expect(disabled).toBe(true);
    });

    it('Primary action should be disabled if the user has not filled the correct project name', async () => {
      wrapper.setProps({ canUserRotateToken: true });
      await wrapper.vm.$nextTick();
      const [{ disabled }] = findGlModal().props('actionPrimary').attributes;
      expect(disabled).toBe(true);
    });

    it('Primary action should be enabled if the user has correctly filled the projectname and can rotate tokens', async () => {
      wrapper.setProps({ canUserRotateToken: true });
      wrapper.setData({ enteredProjectName: projectName });
      await wrapper.vm.$nextTick();
      const [{ disabled }] = findGlModal().props('actionPrimary').attributes;
      expect(disabled).toBe(false);
    });
  });

  describe('rotate token', () => {
    it('should emit a `token` event when clicking on the Primary action', () => {
      findGlModal().vm.$emit('primary', mockEvent);
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted('token')).toEqual([[]]);
        expect(mockEvent.preventDefault.mock.calls.length).toBe(1);
      });
    });

    it('should display an error if there is a rotate error', () => {
      wrapper.setProps({ hasRotateError: true });
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.find('.text-danger')).toExist();
        expect(wrapper.find('[name="warning"]')).toExist();
      });
    });

    it('should clear the project name input after generating the token', async () => {
      wrapper.setProps({ canUserRotateToken: true });
      wrapper.setData({ enteredProjectName: projectName });
      findGlModal().vm.$emit('primary', mockEvent);
      await wrapper.vm.$nextTick();
      expect(findProjectNameInput().element.value).toBe('');
    });
  });

  describe('instance id', () => {
    it('should be displayed in an input box', () => {
      const input = wrapper.find('#instance_id');
      expect(input.element.value).toBe('instance-id-token');
    });
  });

  describe('api url', () => {
    it('should be displayed in an input box', () => {
      const input = wrapper.find('#api_url');
      expect(input.element.value).toBe('/api/url');
    });
  });

  describe('help text', () => {
    it('should be displayed', () => {
      const help = wrapper.find('p');
      expect(help.text()).toMatch(/More Information/);
    });

    it('should have links to the documentation', () => {
      const help = wrapper.find('p');
      const link = help.find('a[href="/help/path"]');
      expect(link.exists()).toBe(true);
      const anchoredLink = help.find('a[href="/help/path/#flags"]');
      expect(anchoredLink.exists()).toBe(true);
    });

    it('should display a warning ', () => {
      const dangerCallout = wrapper
        .findAll(Callout)
        .filter(c => c.props('category') === 'danger')
        .at(0);
      expect(dangerCallout.props('message')).toMatch(/Regenerating the instance ID/);
    });

    it('should display a message asking to fill the project name', () => {
      expect(wrapper.vm.preventAccidentalActionsText).toMatch(projectName);
    });
  });

  describe('project name input', () => {
    it('should provide an input for filling the project name', () => {
      expect(findProjectNameInput().element.value).toBe('');
    });
  });
});
