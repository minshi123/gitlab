import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';

import { GlSkeletonLoader } from '@gitlab/ui';

import createState from '~/static_site_editor/store/state';

import StaticSiteEditor from '~/static_site_editor/components/static_site_editor.vue';
import EditArea from '~/static_site_editor/components/edit_area.vue';
import Toolbar from '~/static_site_editor/components/toolbar.vue';

const localVue = createLocalVue();

localVue.use(Vuex);

describe('StaticSiteEditor', () => {
  let wrapper;
  let store;
  let loadContentActionMock;
  let setContentActionMock;
  let submitChangesActionMock;

  const buildStore = ({ initialState, getters } = {}) => {
    loadContentActionMock = jest.fn();
    setContentActionMock = jest.fn();
    submitChangesActionMock = jest.fn();

    store = new Vuex.Store({
      state: createState(initialState),
      getters: {
        isContentLoaded: () => false,
        contentChanged: () => false,
        ...getters,
      },
      actions: {
        loadContent: loadContentActionMock,
        setContent: setContentActionMock,
        submitChanges: submitChangesActionMock,
      },
    });
  };

  const buildWrapper = () => {
    wrapper = shallowMount(StaticSiteEditor, {
      localVue,
      store,
    });
  };

  const findEditArea = () => wrapper.find(EditArea);
  const findToolbar = () => wrapper.find(Toolbar);
  const findSkeletonLoader = () => wrapper.find(GlSkeletonLoader);

  beforeEach(() => {
    buildStore();
    buildWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when content is not loaded', () => {
    it('does not render edit area', () => {
      expect(findEditArea().exists()).toBe(false);
    });

    it('does not render toolbar', () => {
      expect(findToolbar().exists()).toBe(false);
    });
  });

  describe('when content is loaded', () => {
    const content = 'edit area content';

    beforeEach(() => {
      buildStore({ initialState: { content }, getters: { isContentLoaded: () => true } });
      buildWrapper();
    });

    it('renders the edit area', () => {
      expect(findEditArea().exists()).toBe(true);
    });

    it('does not render skeleton loader', () => {
      expect(findSkeletonLoader().exists()).toBe(false);
    });

    it('passes page content to edit area', () => {
      expect(findEditArea().props('value')).toBe(content);
    });

    it('renders toolbar', () => {
      expect(findToolbar().exists()).toBe(true);
    });
  });

  describe('when edit area emits input event', () => {
    it('dispatches setContent action', () => {
      const content = 'new content';

      buildStore({ getters: { isContentLoaded: () => true } });
      buildWrapper();

      findEditArea().vm.$emit('input', content);

      expect(setContentActionMock).toHaveBeenCalledWith(expect.anything(), content, undefined);
    });
  });

  describe('when saving changes', () => {
    it('sets toolbar as saving changes', () => {
      buildStore({
        initialState: {
          isSavingChanges: true,
        },
        getters: {
          isContentLoaded: () => true,
          contentChanged: () => true,
        },
      });
      buildWrapper();

      expect(findToolbar().props('savingChanges')).toBe(true);
    });
  });

  it('displays skeleton loader while loading content', () => {
    buildStore({ initialState: { isLoadingContent: true } });
    buildWrapper();

    expect(findSkeletonLoader().exists()).toBe(true);
  });

  it('dispatches load content action', () => {
    expect(loadContentActionMock).toHaveBeenCalled();
  });

  describe('when toolbar emits submit event', () => {
    it('dispatches submitChanges  action', () => {
      buildStore({
        getters: {
          isContentLoaded: () => true,
        },
      });
      buildWrapper();
      findToolbar().vm.$emit('submit');

      expect(submitChangesActionMock).toHaveBeenCalled();
    });
  });
});
