const createState = (initialState = {}) => ({
  projectId: null,
  sourcePath: null,

  isLoadingContent: false,
  isContentLoaded: false,

  content: '',

  ...initialState,
});

export default createState;
