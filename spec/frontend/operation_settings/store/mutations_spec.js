import mutations from '~/operation_settings/store/mutations';
import createState from '~/operation_settings/store/state';
import { dashboardTimezoneOptions } from '~/operation_settings/constants';

describe('operation settings mutations', () => {
  let localState;

  beforeEach(() => {
    localState = createState();
  });

  describe('SET_EXTERNAL_DASHBOARD_URL', () => {
    it('sets externalDashboardUrl', () => {
      const mockUrl = 'mockUrl';
      mutations.SET_EXTERNAL_DASHBOARD_URL(localState, mockUrl);

      expect(localState.externalDashboard.url).toBe(mockUrl);
    });
  });

  describe('SET_DASHBOARD_TIMEZONE_SETTING', () => {
    it('sets dashboardTimezoneSetting', () => {
      mutations.SET_DASHBOARD_TIMEZONE_SETTING(localState, dashboardTimezoneOptions.LOCAL);

      expect(localState.dashboardTimezone.setting).not.toBeUndefined();
      expect(localState.dashboardTimezone.setting).toBe(dashboardTimezoneOptions.LOCAL);
    });
  });
});
