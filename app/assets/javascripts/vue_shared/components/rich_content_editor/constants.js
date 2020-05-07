import { __ } from '~/locale';
import { generateToolbarItem } from './toolbar_service';

/* eslint-disable @gitlab/require-i18n-strings */
const TOOLBAR_ITEM_CONFIGS = [
  { icon: 'heading', event: 'openHeadingSelect', class: 'tui-heading', tooltip: __('Headings') },
  { icon: 'bold', command: 'Bold', tooltip: __('Bold') },
  { icon: 'italic', command: 'Italic', tooltip: __('Italic') },
  { icon: 'strikethrough', command: 'Strike', tooltip: __('Strike') },
  { isDivider: true },
  { icon: 'quote', command: 'Blockquote', tooltip: __('Quote') },
  { icon: 'link', event: 'openPopupAddLink', tooltip: __('Insert link') },
  { icon: 'doc-code', command: 'CodeBlock', tooltip: __('Insert code block') },
  { isDivider: true },
  { icon: 'list-bulleted', command: 'UL', tooltip: __('Unordered list') },
  { icon: 'list-numbered', command: 'OL', tooltip: __('Ordered list') },
  { icon: 'list-task', command: 'Task', tooltip: __('Task') },
  { icon: 'list-indent', command: 'Indent', tooltip: __('Indent') },
  { icon: 'list-outdent', command: 'Outdent', tooltip: __('Outdent') },
  { isDivider: true },
  { icon: 'dash', command: 'HR', tooltip: __('Line') },
  { icon: 'table', event: 'openPopupAddTable', class: 'tui-table', tooltip: __('Insert table') },
  { isDivider: true },
  { icon: 'code', command: 'Code', tooltip: __('Inline code') },
];

export const EDITOR_OPTIONS = {
  toolbarItems: TOOLBAR_ITEM_CONFIGS.map(config => generateToolbarItem(config)),
};

export const EDITOR_TYPES = {
  wysiwyg: 'wysiwyg',
};

export const EDITOR_HEIGHT = '100%';
