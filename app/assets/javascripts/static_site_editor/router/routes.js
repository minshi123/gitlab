import Home from '../pages/index.vue';
import Success from '../pages/success/index.vue';

import { ROOT_ROUTE_NAME, SUCCESS_ROUTE_NAME } from './constants';

export default [
  {
    name: ROOT_ROUTE_NAME,
    path: '/',
    component: Home,
  },
  {
    name: SUCCESS_ROUTE_NAME,
    path: '/success',
    component: Success,
  },
];
