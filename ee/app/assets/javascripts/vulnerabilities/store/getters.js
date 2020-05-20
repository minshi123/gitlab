export const discussions = state => Object.values(state.discussionsDictionary);

export const notesDictionary = (state, getters) =>
  getters.discussions
    .flatMap(x => x.notes)
    .reduce((acc, note) => {
      acc[note.id] = note;
      return acc;
    }, {});
