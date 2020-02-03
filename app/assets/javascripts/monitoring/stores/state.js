import invalidUrl from '~/lib/utils/invalid_url';

export default () => ({
  metricsEndpoint: null,
  deploymentsEndpoint: null,
  dashboardEndpoint: invalidUrl,
  emptyState: 'gettingStarted',
  showEmptyState: true,
  showErrorBanner: true,

  /**
   * Dashboard request parameters
   */
  timeRange: null,
  currentDashboard: null,

  /**
   * Dashboard data
   */
  dashboard: {
    panel_groups: [],
  },

  deploymentData: [],
  environments: [],
  environmentsSearchTerm: '',
  environmentsLoading: false,
  allDashboards: [],

  /**
   * Paths to other pages
   */
  projectPath: null,
  logsPath: invalidUrl,
});
