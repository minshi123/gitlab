/*

Based on https://github.com/brijeshb42/monaco-themes/blob/master/themes/Tomorrow-Night.json

The MIT License (MIT)

Copyright (c) Brijesh Bittu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// override VS Dark rules
const rules = [
  { token: '', foreground: 'C5C8C6', background: '1D1F21' }, // chaged
  { token: 'invalid', foreground: 'f44747' },
  { token: 'emphasis', fontStyle: 'italic' },
  { token: 'strong', fontStyle: 'bold' },
  { token: 'keyword.md', foreground: '8ABEB7', fontStyle: 'bold' }, // added

  { token: 'variable', foreground: '81A2BE' }, // changed
  { token: 'variable.js', foreground: '81A2BE' }, // added
  { token: 'variable.predefined', foreground: '4864AA' },
  { token: 'variable.parameter', foreground: '9CDCFE' },
  { token: 'variable.md', foreground: 'B5BD68' }, // added
  { token: 'constant', foreground: '81A2BE' }, // changed
  { token: 'comment', foreground: '608B4E' },
  { token: 'number', foreground: 'B5CEA8' },
  { token: 'number.hex', foreground: '5BB498' },
  { token: 'regexp', foreground: 'B46695' },
  { token: 'annotation', foreground: 'cc6666' },
  { token: 'type', foreground: '3DC9B0' },

  { token: 'delimiter', foreground: 'DCDCDC' },
  { token: 'delimiter.html', foreground: '808080' },
  { token: 'delimiter.xml', foreground: '808080' },

  { token: 'tag', foreground: '569CD6' },
  { token: 'tag.id.jade', foreground: '4F76AC' },
  { token: 'tag.class.jade', foreground: '4F76AC' },
  { token: 'meta.scss', foreground: 'A79873' },
  { token: 'meta.tag', foreground: 'CE9178' },
  { token: 'metatag', foreground: 'DD6A6F' },
  { token: 'metatag.content.html', foreground: '9CDCFE' },
  { token: 'metatag.html', foreground: '569CD6' },
  { token: 'metatag.xml', foreground: '569CD6' },
  { token: 'metatag.php', fontStyle: 'bold' },

  { token: 'key', foreground: '9CDCFE' },
  { token: 'string.key.json', foreground: '9CDCFE' },
  { token: 'string.value.json', foreground: 'CE9178' },

  { token: 'attribute.name', foreground: '9CDCFE' },
  { token: 'attribute.value', foreground: 'CE9178' },
  { token: 'attribute.value.number.css', foreground: 'B5CEA8' },
  { token: 'attribute.value.unit.css', foreground: 'B5CEA8' },
  { token: 'attribute.value.hex.css', foreground: 'D4D4D4' },

  { token: 'string', foreground: 'CE9178' },
  { token: 'string.sql', foreground: 'FF0000' },

  { token: 'keyword', foreground: '569CD6' },
  { token: 'keyword.flow', foreground: 'C586C0' },
  { token: 'keyword.json', foreground: 'CE9178' },
  { token: 'keyword.flow.scss', foreground: '569CD6' },

  { token: 'operator.scss', foreground: '909090' },
  { token: 'operator.sql', foreground: '778899' },
  { token: 'operator.swift', foreground: '909090' },
  { token: 'predefined.sql', foreground: 'FF00FF' },
];

export default {
  base: 'vs-dark',
  inherit: true,
  rules: [
    ...rules,
    {
      foreground: '969896',
      token: 'comment',
    },
    {
      foreground: 'ced1cf',
      token: 'keyword.operator.class',
    },
    {
      foreground: 'ced1cf',
      token: 'constant.other',
    },
    {
      foreground: 'ced1cf',
      token: 'source.php.embedded.line',
    },
    {
      foreground: 'cc6666',
      token: 'variable',
    },
    {
      foreground: 'cc6666',
      token: 'support.other.variable',
    },
    {
      foreground: 'cc6666',
      token: 'string.other.link',
    },
    {
      foreground: 'cc6666',
      token: 'string.regexp',
    },
    {
      foreground: 'cc6666',
      token: 'entity.name.tag',
    },
    {
      foreground: 'cc6666',
      token: 'entity.other.attribute-name',
    },
    {
      foreground: 'cc6666',
      token: 'meta.tag',
    },
    {
      foreground: 'cc6666',
      token: 'declaration.tag',
    },
    {
      foreground: 'cc6666',
      token: 'markup.deleted.git_gutter',
    },
    {
      foreground: 'de935f',
      token: 'constant.numeric',
    },
    {
      foreground: 'de935f',
      token: 'constant.language',
    },
    {
      foreground: 'de935f',
      token: 'support.constant',
    },
    {
      foreground: 'de935f',
      token: 'constant.character',
    },
    {
      foreground: 'de935f',
      token: 'variable.parameter',
    },
    {
      foreground: 'de935f',
      token: 'punctuation.section.embedded',
    },
    {
      foreground: 'de935f',
      token: 'keyword.other.unit',
    },
    {
      foreground: 'f0c674',
      token: 'entity.name.class',
    },
    {
      foreground: 'f0c674',
      token: 'entity.name.type.class',
    },
    {
      foreground: 'f0c674',
      token: 'support.type',
    },
    {
      foreground: 'f0c674',
      token: 'support.class',
    },
    {
      foreground: 'b5bd68',
      token: 'string',
    },
    {
      foreground: 'b5bd68',
      token: 'constant.other.symbol',
    },
    {
      foreground: 'b5bd68',
      token: 'entity.other.inherited-class',
    },
    {
      foreground: 'b5bd68',
      token: 'markup.heading',
    },
    {
      foreground: 'b5bd68',
      token: 'markup.inserted.git_gutter',
    },
    {
      foreground: '8abeb7',
      token: 'keyword.operator',
    },
    {
      foreground: '8abeb7',
      token: 'constant.other.color',
    },
    {
      foreground: '81a2be',
      token: 'entity.name.function',
    },
    {
      foreground: '81a2be',
      token: 'meta.function-call',
    },
    {
      foreground: '81a2be',
      token: 'support.function',
    },
    {
      foreground: '81a2be',
      token: 'keyword.other.special-method',
    },
    {
      foreground: '81a2be',
      token: 'meta.block-level',
    },
    {
      foreground: '81a2be',
      token: 'markup.changed.git_gutter',
    },
    {
      foreground: 'b294bb',
      token: 'keyword',
    },
    {
      foreground: 'b294bb',
      token: 'storage',
    },
    {
      foreground: 'b294bb',
      token: 'storage.type',
    },
    {
      foreground: 'b294bb',
      token: 'entity.name.tag.css',
    },
    {
      foreground: 'ced2cf',
      background: 'df5f5f',
      token: 'invalid',
    },
    {
      foreground: 'ced2cf',
      background: '82a3bf',
      token: 'meta.separator',
    },
    {
      foreground: 'ced2cf',
      background: 'b798bf',
      token: 'invalid.deprecated',
    },
    {
      foreground: 'ffffff',
      token: 'markup.inserted.diff',
    },
    {
      foreground: 'ffffff',
      token: 'markup.deleted.diff',
    },
    {
      foreground: 'ffffff',
      token: 'meta.diff.header.to-file',
    },
    {
      foreground: 'ffffff',
      token: 'meta.diff.header.from-file',
    },
    {
      foreground: '718c00',
      token: 'markup.inserted.diff',
    },
    {
      foreground: '718c00',
      token: 'meta.diff.header.to-file',
    },
    {
      foreground: 'c82829',
      token: 'markup.deleted.diff',
    },
    {
      foreground: 'c82829',
      token: 'meta.diff.header.from-file',
    },
    {
      foreground: 'ffffff',
      background: '4271ae',
      token: 'meta.diff.header.from-file',
    },
    {
      foreground: 'ffffff',
      background: '4271ae',
      token: 'meta.diff.header.to-file',
    },
    {
      foreground: '3e999f',
      fontStyle: 'italic',
      token: 'meta.diff.range',
    },
  ],
  colors: {
    'editor.foreground': '#C5C8C6',
    'editor.background': '#1D1F21',
    'editor.selectionBackground': '#373B41',
    'editor.lineHighlightBackground': '#282A2E',
    'editorCursor.foreground': '#AEAFAD',
    'editorWhitespace.foreground': '#4B4E55',
  },
};
