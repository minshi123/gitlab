export default () => ({
  // Initial Data
  labels: [],

  // Paths
  namespace: '',
  labelFilterBasePath: '',
  scopedLabelsDocumentationPath: '#',

  // UI Flags
  allowLabelCreate: false,
  allowLabelEdit: false,
  allowScopedLabels: false,
  dropdownOnly: false,
  labelsSelectInProgress: false,
  labelsFetchInProgress: false,
});
