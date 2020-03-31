import createFlash from '~/flash';
import { __ } from '~/locale';

import * as mutationTypes from './mutation_types';
import loadSourceContent from '~/static_site_editor/services/load_source_content';

export const loadContent = ({ commit, dispatch, state: { sourcePath, projectId } }) => {
  commit(mutationTypes.LOAD_CONTENT);

  return loadSourceContent({ sourcePath, projectId })
    .then(content => dispatch('receiveContentSuccess', content))
    .catch(() => {
      dispatch('receiveContentError');
      createFlash(__('An error ocurred while loading your content. Please try again.'));
    });
};

export const receiveContentSuccess = ({ commit }, content) => {
  commit(mutationTypes.RECEIVE_CONTENT_SUCCESS, content);
};

export const receiveContentError = ({ commit }) => {
  commit(mutationTypes.RECEIVE_CONTENT_ERROR);
};

export default () => {};
