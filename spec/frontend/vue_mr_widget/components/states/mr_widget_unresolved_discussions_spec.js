import { mount } from '@vue/test-utils';
import Vuex from 'vuex';
import Mousetrap from 'mousetrap';
import Vue from 'vue';
import UnresolvedDiscussions from '~/vue_merge_request_widget/components/states/unresolved_discussions.vue';
import { TEST_HOST } from 'helpers/test_constants';

function makeStore({ count, setCurrentDiscussionIdSpy }) {
  return new Vuex.Store({
    actions: {
      setCurrentDiscussionId: setCurrentDiscussionIdSpy,
    },
    getters: {
      unresolvedDiscussionsCount: () => count,
    },
  });
}

function mountWithPathAndUnresolvedCount({
  path = null,
  count = 1,
  setCurrentDiscussionIdSpy = jest.fn(),
} = {}) {
  return mount(Vue.extend(UnresolvedDiscussions), {
    store: makeStore({ count, setCurrentDiscussionIdSpy }),
    propsData: {
      mr: {
        createIssueToResolveDiscussionsPath: path,
      },
    },
  });
}

describe('UnresolvedDiscussions', () => {
  const UNRESOLVED_THREADS = 5;
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
  });

  it.each`
    unresolved | text
    ${0}       | ${'0 threads'}
    ${1}       | ${'1 thread'}
    ${2}       | ${'2 threads'}
  `('shows the correct text for $unresolved unresolved discussions', ({ unresolved, text }) => {
    wrapper = mountWithPathAndUnresolvedCount({ count: unresolved });

    expect(wrapper.element.innerText).toContain(
      `Before this can be merged, ${text} must be resolved.`,
    );
  });

  it('moves to the first discussion when the jump to first unresolved discussion button is clicked', () => {
    const mousetrapSpy = jest.spyOn(Mousetrap, 'trigger');
    const spy = jest.fn();

    wrapper = mountWithPathAndUnresolvedCount({ setCurrentDiscussionIdSpy: spy });

    wrapper.find('.btn-group button.gl-button:first-of-type').trigger('click');

    expect(spy).toHaveBeenCalledWith(expect.any(Object), null, undefined);
    expect(mousetrapSpy).toHaveBeenCalledWith('n');
  });

  describe('with threads path', () => {
    beforeEach(() => {
      wrapper = mountWithPathAndUnresolvedCount({ path: TEST_HOST, count: UNRESOLVED_THREADS });
    });

    it('should have correct elements', () => {
      expect(wrapper.element.innerText).toContain(
        `Before this can be merged, ${UNRESOLVED_THREADS} threads must be resolved.`,
      );

      expect(wrapper.element.innerText).toContain('Jump to first unresolved thread');
      expect(wrapper.element.innerText).toContain('Resolve all threads in new issue');
      expect(wrapper.element.querySelector('.js-create-issue').getAttribute('href')).toEqual(
        TEST_HOST,
      );
    });
  });

  describe('without threads path', () => {
    beforeEach(() => {
      wrapper = mountWithPathAndUnresolvedCount({ count: UNRESOLVED_THREADS });
    });

    it('should not show create issue link if user cannot create issue', () => {
      expect(wrapper.element.innerText).toContain(
        `Before this can be merged, ${UNRESOLVED_THREADS} threads must be resolved.`,
      );

      expect(wrapper.element.innerText).toContain('Jump to first unresolved thread');
      expect(wrapper.element.innerText).not.toContain('Resolve all threads in new issue');
      expect(wrapper.element.querySelector('.js-create-issue')).toEqual(null);
    });
  });
});
