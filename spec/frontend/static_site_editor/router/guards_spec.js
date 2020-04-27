import { doNotDisplaySuccessPage } from '~/static_site_editor/router/guards';
import { SUCCESS_ROUTE_NAME, ROOT_ROUTE_NAME } from '~/static_site_editor/router/constants';
import { savedContentMeta } from '../mock_data';

describe('static_site_editor/router/guards', () => {
  let next;

  beforeEach(() => {
    next = jest.fn();
  });

  describe('doNotDisplaySuccessPage when route is SUCCESS_ROUTE', () => {
    const to = { name: SUCCESS_ROUTE_NAME };

    it('enters route when saved content meta is available', () => {
      const store = { state: { savedContentMeta } };

      doNotDisplaySuccessPage(store)(to, null, next);

      expect(next).toHaveBeenCalled();
      expect(next.mock.calls[0]).toHaveLength(0);
    });

    it('redirects to ROOT when saved content meta is not available', () => {
      const store = { state: { savedContentMeta: null } };

      doNotDisplaySuccessPage(store)(to, null, next);

      expect(next).toHaveBeenCalledWith({ name: ROOT_ROUTE_NAME });
    });
  });
});
