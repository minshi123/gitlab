import { editor as monacoEditor, languages as monacoLanguages, Uri, Position } from 'monaco-editor';
import gitlabTheme from '~/ide/lib/themes/gl_theme';
import { defaultEditorOptions } from '~/ide/lib/editor_options';
import { clearDomElement } from '~/ide/lib/editor';

function setupMonacoTheme() {
  monacoEditor.defineTheme(gitlabTheme.themeName, gitlabTheme.monacoTheme);
  monacoEditor.setTheme('gitlab');
}

export default class Editor {
  constructor({ domEl = undefined, path = '', content ='', options = {} }) {

    this.domEl = domEl;
    this.path = path;
    this.content = content;

    setupMonacoTheme();

    this.options = {
      ...defaultEditorOptions,
      ...options,
    };

    this.clearView();
    this.createInstance();
  }

  static getSelectedText() {
    return monacoEditor.getSelection().toString();
  }

  static navigateFileStart() {
    return new Position(1,1);
  }

  clearView() {
    clearDomElement(this.domEl);
  }

  createInstance() {
    this.createModel();
    this.options = Object.assign(this.options, {
      model: this.model
    });
    if(!this.instance) {
      this.instance = monacoEditor.create(this.domEl, this.options);
    }
  }

  createModel() {
    this.model = monacoEditor.createModel(this.content, undefined, new Uri('gitlab', false, this.path));
  }

  updateModelLanguage(path) {
    if(path === this.path) return;
    this.path = path;
    const ext = `.${path.split('.').pop()}`;
    const language = monacoLanguages.getLanguages().find(lang => lang.extensions.indexOf(ext) !== -1);
    monacoEditor.setModelLanguage(this.model, language.id);
  }

  getValue() {
    return this.instance.getValue();
  }

  setValue(newValue) {
    this.instance.setValue(newValue);
  }

  focus() {
    this.domEl.focus();
  }
};
