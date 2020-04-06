const createState = (initialState = {}) => ({
  projectId: null,
  sourcePath: null,

  isLoadingContent: false,
  isSavingChanges: false,

  content: '',
  title: '',

  ...initialState,
});

export default createState;
