import Editor from '~/editor/editor_lite';

describe('Base editor', () => {
  let editorEl;

  beforeEach(() => {
    setFixtures('<div id="editor" data-editor-loading></div>');
    editorEl = document.getElementById('editor');
  });

  afterEach(() => {
    editorEl.remove();
  });

  it('does nothing if no dom element is specified', () => {
    const editor = new Editor();

    expect(editorEl.dataset.editorLoading).toBe(true);
  });
});