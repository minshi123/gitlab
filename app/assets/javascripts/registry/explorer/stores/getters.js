// eslint-disable-next-line import/prefer-default-export
export const tags = state => {
  return state.isLoading ? [] : state.tags;
};
