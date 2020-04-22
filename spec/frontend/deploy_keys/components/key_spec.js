import { mount } from '@vue/test-utils';
import DeployKeysStore from '~/deploy_keys/store';
import key from '~/deploy_keys/components/key.vue';
import { getTimeago } from '~/lib/utils/datetime_utility';

describe('Deploy keys key', () => {
  let wrapper;
  let store;

  const data = getJSONFixture('deploy_keys/keys.json');
  const createComponent = deployKey => {
    store = new DeployKeysStore();
    store.keys = data;

    wrapper = mount(key, {
      propsData: {
        deployKey,
        store,
        endpoint: 'https://test.host/dummy/endpoint',
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('enabled key', () => {
    const deployKey = data.enabled_keys[0];

    it('renders the keys title', () => {
      createComponent(deployKey);

      expect(
        wrapper
          .find('.title')
          .text()
          .trim(),
      ).toContain('My title');
    });

    it('renders human friendly formatted created date', () => {
      createComponent(deployKey);

      expect(
        wrapper
          .find('.key-created-at')
          .text()
          .trim(),
      ).toBe(`${getTimeago().format(deployKey.created_at)}`);
    });

    it('shows pencil button for editing', () => {
      createComponent(deployKey);

      expect(wrapper.find('.btn .ic-pencil')).toExist();
    });

    it('shows disable button when the project is not deletable', () => {
      createComponent(deployKey);

      expect(wrapper.find('.btn .ic-cancel')).toExist();
    });

    it('shows remove button when the project is deletable', () => {
      createComponent({ ...deployKey, destroyed_when_orphaned: true, almost_orphaned: true });
      expect(wrapper.find('.btn .ic-remove')).toExist();
    });
  });

  describe('deploy key labels', () => {
    const deployKey = data.enabled_keys[0];
    const deployKeysProjects = [...deployKey.deploy_keys_projects];
    it('shows write access title when key has write access', () => {
      deployKeysProjects[0] = { ...deployKeysProjects[0], can_push: true };
      createComponent({ ...deployKey, deploy_keys_projects: deployKeysProjects });

      expect(wrapper.find('.deploy-project-label').attributes('data-original-title')).toBe(
        'Write access allowed',
      );
    });

    it('does not show write access title when key has write access', () => {
      deployKeysProjects[0] = { ...deployKeysProjects[0], can_push: false };
      createComponent({ ...deployKey, deploy_keys_projects: deployKeysProjects });

      expect(wrapper.find('.deploy-project-label').attributes('data-original-title')).toBe(
        'Read access only',
      );
    });

    it('shows expandable button if more than two projects', () => {
      createComponent(deployKey);
      const labels = wrapper.findAll('.deploy-project-label');

      expect(labels.length).toBe(2);
      expect(labels.at(1).text()).toContain('others');
      expect(labels.at(1).attributes('data-original-title')).toContain('Expand');
    });

    it('expands all project labels after click', () => {
      createComponent(deployKey);
      const { length } = deployKey.deploy_keys_projects;
      wrapper
        .findAll('.deploy-project-label')
        .at(1)
        .trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        const labels = wrapper.findAll('.deploy-project-label');

        expect(labels.length).toBe(length);
        expect(labels.at(1).text()).not.toContain(`+${length} others`);
        expect(labels.at(1).attributes('data-original-title')).not.toContain('Expand');
      });
    });

    it('shows two projects', () => {
      createComponent({ ...deployKey, deploy_keys_projects: [...deployKeysProjects].slice(0, 2) });

      const labels = wrapper.findAll('.deploy-project-label');

      expect(labels.length).toBe(2);
      expect(labels.at(1).text()).toContain(deployKey.deploy_keys_projects[1].project.full_name);
    });
  });

  describe('public keys', () => {
    const deployKey = data.public_keys[0];

    it('renders deploy keys without any enabled projects', () => {
      createComponent({ ...deployKey, deploy_keys_projects: [] });

      expect(
        wrapper
          .find('.deploy-project-list')
          .text()
          .trim(),
      ).toBe('None');
    });

    it('shows enable button', () => {
      createComponent(deployKey);
      expect(
        wrapper
          .findAll('.btn')
          .at(0)
          .text()
          .trim(),
      ).toBe('Enable');
    });

    it('shows pencil button for editing', () => {
      createComponent(deployKey);
      expect(wrapper.find('.btn .ic-pencil')).toExist();
    });

    it('shows disable button when key is enabled', () => {
      createComponent(deployKey);
      store.keys.enabled_keys.push(deployKey);

      expect(wrapper.find('.btn .ic-cancel')).toExist();
    });
  });
});
