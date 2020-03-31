import createState from '~/static_site_editor/store/state';
import mutations from '~/static_site_editor/store/mutations';
import * as types from '~/static_site_editor/store/mutation_types';

describe('Static Site Editor Store mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('loadContent', () => {
    beforeEach(() => {
      Object.assign(state, {
        isLoadingContent: false,
        isContentLoaded: true,
      });

      mutations[types.LOAD_CONTENT](state);
    });

    it('sets isLoadingContent to true', () => {
      expect(state.isLoadingContent).toBe(true);
    });

    it('sets isContentLoaded to false', () => {
      expect(state.isContentLoaded).toBe(false);
    });
  });

  describe('receiveContentSuccess', () => {
    const payload = { content: 'foobar' };

    beforeEach(() => {
      Object.assign(state, {
        isLoadingContent: true,
        isContentLoaded: false,
      });
      mutations[types.RECEIVE_CONTENT_SUCCESS](state, payload);
    });

    it('sets isLoadingContent to false', () => {
      expect(state.isLoadingContent).toBe(false);
    });

    it('sets isContentLoaded to true', () => {
      expect(state.isContentLoaded).toBe(true);
    });

    it('sets content', () => {
      expect(state.content).toBe(payload.content);
    });
  });

  describe('receiveContentError', () => {
    beforeEach(() => {
      Object.assign(state, {
        isLoadingContent: true,
        isContentLoaded: true,
      });
      mutations[types.RECEIVE_CONTENT_ERROR](state);
    });

    it('sets isLoadingContent to false', () => {
      expect(state.isLoadingContent).toBe(false);
    });

    it('sets isContentLoaded to false', () => {
      expect(state.isContentLoaded).toBe(false);
    });
  });
});
