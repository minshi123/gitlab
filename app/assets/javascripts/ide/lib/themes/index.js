import white from './white';
import dark from './dark';
import solarizedDark from './solarized_dark';

export const themes = [
  {
    name: 'white',
    data: white,
  },
  {
    name: 'dark',
    data: dark,
  },
  {
    name: 'solarized-dark',
    data: solarizedDark,
  },
];

export const DEFAULT_THEME = 'white';
