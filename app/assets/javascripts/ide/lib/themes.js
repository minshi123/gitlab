import gitlab from './themes/gitlab';
import dark from './themes/dark';

export default [
  {
    id: 1,
    name: 'gitlab',
    data: gitlab,
  },
  {
    id: 2,
    name: 'dark',
    data: dark,
  },
];

export const DEFAULT_THEME = 'gitlab';
