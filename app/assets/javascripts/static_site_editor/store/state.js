const createState = (initialState = {}) => ({
  projectId: null,
  returnUrl: null,
  sourcePath: null,

  isLoadingContent: false,

  content: '',
  title: '',

  ...initialState,
});

export default createState;
