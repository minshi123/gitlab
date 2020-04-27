import { SUCCESS_ROUTE, HOME_ROUTE } from './constants';

// eslint-disable-next-line import/prefer-default-export
export const doNotDisplaySuccessPage = store => (to, from, next) => {
  if (to.name === SUCCESS_ROUTE.name && !store.state.savedContentMeta) {
    return next(HOME_ROUTE);
  }

  return next();
};
