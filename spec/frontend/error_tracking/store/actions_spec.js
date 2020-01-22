import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import * as actions from '~/error_tracking/store/actions';
import * as types from '~/error_tracking/store/mutation_types';
import { visitUrl } from '~/lib/utils/url_utility';

jest.mock('~/flash.js');
jest.mock('~/lib/utils/url_utility');

let mock;

describe('Sentry common store actions', () => {
  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    createFlash.mockClear();
  });
  describe('updateStatus', () => {
    const endpoint = '123/stacktrace';
    const redirectUrl = '/list';
    const status = 'resolved';

    it('should handle successful status update', done => {
      mock.onPut().reply(200, {});
      testAction(
        actions.updateStatus,
        { endpoint, redirectUrl, status },
        {},
        [
          {
            payload: 'resolved',
            type: types.SET_ERROR_STATUS,
          },
          {
            payload: false,
            type: types.SET_UPDATING_RESOLVE_STATUS,
          },
          {
            payload: false,
            type: types.SET_UPDATING_IGNORE_STATUS,
          },
        ],
        [],
        () => {
          done();
          expect(visitUrl).toHaveBeenCalledWith(redirectUrl);
        },
      );
    });

    it('should handle unsuccessful status update', done => {
      mock.onPut().reply(400, {});
      testAction(
        actions.updateStatus,
        { endpoint, redirectUrl, status },
        {},
        [
          {
            payload: false,
            type: types.SET_UPDATING_RESOLVE_STATUS,
          },
          {
            payload: false,
            type: types.SET_UPDATING_IGNORE_STATUS,
          },
        ],
        [],
        () => {
          expect(visitUrl).not.toHaveBeenCalled();
          expect(createFlash).toHaveBeenCalledTimes(1);
          done();
        },
      );
    });
  });

  describe('setUpdatingResolveStatus', () => {
    it('should handle successful status update', () => {
      testAction(
        actions.setUpdatingResolveStatus,
        true,
        {},
        [
          {
            payload: true,
            type: types.SET_UPDATING_RESOLVE_STATUS,
          },
        ],
        [],
      );
    });
  });

  describe('setUpdatingIgnoreStatus', () => {
    it('should handle successful status update', () => {
      testAction(
        actions.setUpdatingIgnoreStatus,
        false,
        {},
        [
          {
            payload: false,
            type: types.SET_UPDATING_IGNORE_STATUS,
          },
        ],
        [],
      );
    });
  });
});
