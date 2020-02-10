export const SimpleViewerMock = {
  collapsed: false,
  loadingPartialName: 'loading',
  renderError: null,
  tooLarge: false,
  type: 'simple',
  fileType: 'text',
};

export const RichViewerMock = {
  collapsed: false,
  loadingPartialName: 'loading',
  renderError: null,
  tooLarge: false,
  type: 'rich',
  fileType: 'markdown',
};

export const Blob = {
  binary: false,
  name: 'dummy.md',
  path: 'dummy.md',
  rawPath: '/flightjs/flight/snippets/51/raw',
  size: 75,
  simpleViewer: {
    ...SimpleViewerMock,
  },
  richViewer: {
    ...RichViewerMock,
  },
};

export const RichBlobContentMock = {
  richData: '<h1>Rich</h1>',
};

export const SimpleBlobContentMock = {
  plainData: 'Plain',
};

export default {};
