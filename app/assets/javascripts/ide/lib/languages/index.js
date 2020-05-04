import { languages as monacoLanguages } from 'monaco-editor';
import vue from './vue';

export function registerLanguage(def) {
  const languageId = def.id;

  monacoLanguages.register(def);
  monacoLanguages.setMonarchTokensProvider(languageId, def.language);
  monacoLanguages.setLanguageConfiguration(languageId, def.conf);

  return def;
}

export const languages = [vue];
