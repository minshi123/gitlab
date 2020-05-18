import DashboardPage from '../pages/dashboard_page.vue';

import { DASHBOARD_PAGE_ROUTE } from './constants';

export default [
  {
    ...DASHBOARD_PAGE_ROUTE,
    path: '/',
    component: DashboardPage,
  },
  {
    path: '*',
    redirect: DASHBOARD_PAGE_ROUTE,
  },
];
