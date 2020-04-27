import { SUCCESS_ROUTE_NAME, ROOT_ROUTE_NAME } from './constants';

// eslint-disable-next-line import/prefer-default-export
export const doNotDisplaySuccessPage = store => (to, from, next) => {
  if (to.name === SUCCESS_ROUTE_NAME && !store.state.savedContentMeta) {
    return next({ name: ROOT_ROUTE_NAME });
  }

  return next();
};
