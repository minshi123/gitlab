export default (initialState = {}) => ({
  operationsSettingsEndpoint: initialState.operationsSettingsEndpoint,
  helpPage: initialState.helpPage,
  externalDashboard: {
    url: initialState.externalDashboardUrl,
    helpPage: initialState.externalDashboardHelpPage,
  },
  dashboardTimezone: {
    setting: initialState.dashboardTimezoneSetting,
    helpPage: initialState.dashboardTimezoneHelpPage,
  }
});
