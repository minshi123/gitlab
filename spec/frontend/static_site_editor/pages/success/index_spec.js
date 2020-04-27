import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';

import createState from '~/static_site_editor/store/state';

import Index from '~/static_site_editor/pages/success/index.vue';
import SavedChangesMessage from '~/static_site_editor/components/saved_changes_message.vue';

import { savedContentMeta, returnUrl } from '../../mock_data';

const localVue = createLocalVue();

localVue.use(Vuex);

describe('static_site_editor/pages/success', () => {
  let wrapper;
  let store;

  const buildStore = () => {
    store = new Vuex.Store({
      state: createState({
        savedContentMeta,
        returnUrl,
      }),
    });
  };

  const buildWrapper = () => {
    wrapper = shallowMount(Index, {
      localVue,
      store,
    });
  };

  const findSavedChangesMessage = () => wrapper.find(SavedChangesMessage);

  beforeEach(() => {
    buildStore();
    buildWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders saved changes message', () => {
    expect(findSavedChangesMessage().exists()).toBe(true);
  });

  it('passes returnUrl to the saved changes message', () => {
    expect(findSavedChangesMessage().props('returnUrl')).toBe(returnUrl);
  });

  it('passes saved content metadata to the saved changes message', () => {
    expect(findSavedChangesMessage().props('branch')).toBe(savedContentMeta.branch);
    expect(findSavedChangesMessage().props('commit')).toBe(savedContentMeta.commit);
    expect(findSavedChangesMessage().props('mergeRequest')).toBe(savedContentMeta.mergeRequest);
  });
});
