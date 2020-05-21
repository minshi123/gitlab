import { mapGetters, mapActions, mapState } from 'vuex';
import { scrollToElement } from '~/lib/utils/common_utils';
import eventHub from '../event_hub';

/**
 * @param {string} selector
 * @param {boolean} offset Additional offset to subtract from element
 * @returns {boolean}
 */
function scrollTo(selector, offset = 0) {
  const el = document.querySelector(selector);

  if (el) {
    scrollToElement(el, offset);
    return true;
  }

  return false;
}

/**
 * @param {object} self Component instance with mixin applied
 * @param {string} id Discussion id we are jumping to
 */
function diffsJump({ expandDiscussion }, id, isMobile) {
  const selector = `ul.notes[data-discussion-id="${id}"]`;

  const offset = isMobile ? 32 : 80;
  eventHub.$once('scrollToDiscussion', () => scrollTo(selector, offset));
  expandDiscussion({ discussionId: id });
}

/**
 * @param {object} self Component instance with mixin applied
 * @param {string} id Discussion id we are jumping to
 * @returns {boolean}
 */
function discussionJump({ expandDiscussion }, id) {
  const selector = `div.discussion[data-discussion-id="${id}"]`;
  expandDiscussion({ discussionId: id });
  return scrollTo(selector);
}

/**
 * @param {object} self Component instance with mixin applied
 * @param {string} id Discussion id we are jumping to
 */
function switchToDiscussionsTabAndJumpTo(self, id) {
  window.mrTabs.eventHub.$once('MergeRequestTabChange', () => {
    setTimeout(() => discussionJump(self, id), 0);
  });

  window.mrTabs.tabShown('show');
}

/**
 * @param {object} self Component instance with mixin applied
 * @param {object} discussion Discussion we are jumping to
 * @param {boolean} isMobile If on mobile screen size (md, sm, xs)
 */
function jumpToDiscussion(self, discussion, isMobile) {
  const { id, diff_discussion: isDiffDiscussion } = discussion;
  if (id) {
    const activeTab = window.mrTabs.currentAction;

    if (activeTab === 'diffs' && isDiffDiscussion) {
      diffsJump(self, id, isMobile);
    } else if (activeTab === 'show') {
      discussionJump(self, id);
    } else {
      switchToDiscussionsTabAndJumpTo(self, id);
    }
  }
}

/**
 * @param {object} self Component instance with mixin applied
 * @param {function} fn Which function used to get the target discussion's id
 * @param {string} [discussionId=this.currentDiscussionId] Current discussion id, will be null if discussions have not been traversed yet
 * @param {boolean} isMobile If on mobile screen size (md, sm, xs)
 */
function handleDiscussionJump(self, fn, discussionId = self.currentDiscussionId, isMobile) {
  const isDiffView = window.mrTabs.currentAction === 'diffs';
  const targetId = fn(discussionId, isDiffView);
  const discussion = self.getDiscussion(targetId);
  jumpToDiscussion(self, discussion, isMobile);
  self.setCurrentDiscussionId(targetId);
}

export default {
  computed: {
    ...mapGetters([
      'nextUnresolvedDiscussionId',
      'previousUnresolvedDiscussionId',
      'getDiscussion',
    ]),
    ...mapState({
      currentDiscussionId: state => state.notes.currentDiscussionId,
    }),
  },
  methods: {
    ...mapActions(['expandDiscussion', 'setCurrentDiscussionId']),

    jumpToNextDiscussion() {
      handleDiscussionJump(this, this.nextUnresolvedDiscussionId);
    },

    jumpToPreviousDiscussion() {
      handleDiscussionJump(this, this.previousUnresolvedDiscussionId);
    },

    /**
     * Go to the next discussion from the given discussionId
     * @param {String} discussionId The id we are jumping from
     * @param {Boolean} isMobile If on mobile screen size (md, sm, xs)
     */
    jumpToNextRelativeDiscussion(discussionId, isMobile) {
      handleDiscussionJump(this, this.nextUnresolvedDiscussionId, discussionId, isMobile);
    },
  },
};
