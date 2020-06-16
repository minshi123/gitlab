import EpicHeader from 'ee/epic/components/epic_header.vue';
import createStore from 'ee/epic/store';
import { mount } from '@vue/test-utils';
import { statusType } from 'ee/epic/constants';

import { mockEpicMeta, mockEpicData } from '../mock_data';

describe('EpicHeaderComponent', () => {
  let wrapper;
  let store;
  let features = {};

  const createWrapper = () => {
    store = createStore();

    store.dispatch('setEpicMeta', mockEpicMeta);
    store.dispatch('setEpicData', mockEpicData);

    wrapper = mount(EpicHeader, {
      store,
      provide: {
        glFeatures: features,
      },
    });
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('computed', () => {
    describe('statusIcon', () => {
      it('returns string `issue-open-m` when `isEpicOpen` is true', () => {
        store.state.state = statusType.open;

        expect(wrapper.vm.statusIcon).toBe('issue-open-m');
      });

      it('returns string `mobile-issue-close` when `isEpicOpen` is false', () => {
        store.state.state = statusType.close;

        expect(wrapper.vm.statusIcon).toBe('mobile-issue-close');
      });
    });

    describe('statusText', () => {
      it('returns string `Open` when `isEpicOpen` is true', () => {
        store.state.state = statusType.open;

        expect(wrapper.vm.statusText).toBe('Open');
      });

      it('returns string `Closed` when `isEpicOpen` is false', () => {
        store.state.state = statusType.close;

        expect(wrapper.vm.statusText).toBe('Closed');
      });
    });

    describe('actionButtonClass', () => {
      it('returns default button classes along with `btn-close` when `isEpicOpen` is true', () => {
        store.state.state = statusType.open;

        expect(wrapper.vm.actionButtonClass).toBe(
          'btn btn-grouped js-btn-epic-action qa-close-reopen-epic-button btn-close',
        );
      });

      it('returns default button classes along with `btn-open` when `isEpicOpen` is false', () => {
        store.state.state = statusType.close;

        expect(wrapper.vm.actionButtonClass).toBe(
          'btn btn-grouped js-btn-epic-action qa-close-reopen-epic-button btn-open',
        );
      });
    });

    describe('actionButtonText', () => {
      it('returns string `Close epic` when `isEpicOpen` is true', () => {
        store.state.state = statusType.open;

        expect(wrapper.vm.actionButtonText).toBe('Close epic');
      });

      it('returns string `Reopen epic` when `isEpicOpen` is false', () => {
        store.state.state = statusType.close;

        expect(wrapper.vm.actionButtonText).toBe('Reopen epic');
      });
    });
  });

  describe('template', () => {
    it('renders component container element with class `detail-page-header`', () => {
      expect(wrapper.vm.$el.classList.contains('detail-page-header')).toBe(true);
      expect(wrapper.vm.$el.querySelector('.detail-page-header-body')).not.toBeNull();
    });

    it('renders epic status icon and text elements', () => {
      const statusEl = wrapper.vm.$el.querySelector('.issuable-status-box');

      expect(statusEl).not.toBeNull();
      expect(
        statusEl.querySelector('svg.ic-issue-open-m use').getAttribute('xlink:href'),
      ).toContain('issue-open-m');

      expect(statusEl.querySelector('span').innerText.trim()).toBe('Open');
    });

    it('renders epic author details element', () => {
      const metaEl = wrapper.vm.$el.querySelector('.issuable-meta');

      expect(metaEl).not.toBeNull();
      expect(metaEl.querySelector('strong a.user-avatar-link')).not.toBeNull();
    });

    it('renders action buttons element', () => {
      const actionsEl = wrapper.vm.$el.querySelector('.js-issuable-actions');

      expect(actionsEl).not.toBeNull();
      expect(actionsEl.querySelector('.js-btn-epic-action')).not.toBeNull();
      expect(actionsEl.querySelector('.js-btn-epic-action').innerText.trim()).toBe('Close epic');
    });

    it('renders toggle sidebar button element', () => {
      const toggleButtonEl = wrapper.vm.$el.querySelector('button.js-sidebar-toggle');

      expect(toggleButtonEl).not.toBeNull();
      expect(toggleButtonEl.getAttribute('aria-label')).toBe('Toggle sidebar');
      expect(toggleButtonEl.classList.contains('d-block')).toBe(true);
      expect(toggleButtonEl.classList.contains('d-sm-none')).toBe(true);
      expect(toggleButtonEl.classList.contains('gutter-toggle')).toBe(true);
    });

    it('renders GitLab team member badge when `author.isGitlabEmployee` is `true`', () => {
      store.state.author.isGitlabEmployee = true;

      // Wait for dynamic imports to resolve
      return new Promise(setImmediate).then(() => {
        expect(wrapper.vm.$refs.gitlabTeamMemberBadge).not.toBeUndefined();
      });
    });

    it('does not render new epic button without `createEpicForm` feature flag', () => {
      const newEpicButton = wrapper.vm.$el.querySelector('.js-new-epic-button');

      expect(newEpicButton).toBeNull();
    });

    describe('with `createEpicForm` feature flag', () => {
      beforeAll(() => {
        features = { createEpicForm: true };
      });

      it('renders new epic button if user can create it', () => {
        store.state.canCreate = true;

        return wrapper.vm.$nextTick().then(() => {
          const newEpicButton = wrapper.vm.$el.querySelector('.js-new-epic-button');
          expect(newEpicButton).not.toBeNull();
        });
      });
    });
  });
});
