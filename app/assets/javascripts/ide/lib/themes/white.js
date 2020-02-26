/*
Based on https://github.com/brijeshb42/monaco-themes/blob/master/themes/GitHub.json

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

const rules = [
  { token: '', foreground: '000000', background: 'fffffe' },
  { token: 'invalid', foreground: 'cd3131' },
  { token: 'emphasis', fontStyle: 'italic' },
  { token: 'strong', fontStyle: 'bold' },
  { token: 'keyword.css', fontStyle: 'bold', foreground: '999999' }, // added
  { token: 'keyword.less', fontStyle: 'bold', foreground: '999999' }, // added
  { token: 'keyword.scss', fontStyle: 'bold', foreground: '999999' }, // added

  { token: 'variable', foreground: '001188' },
  { token: 'variable.predefined', foreground: '008080' }, // changed
  { token: 'constant', foreground: 'dd0000' },
  { token: 'comment', foreground: '008000' },
  { token: 'number', foreground: '009999' }, // changed
  { token: 'number.hex', foreground: '3030c0' },
  { token: 'regexp', foreground: '800000' },
  { token: 'annotation', foreground: '808080' },
  { token: 'type', foreground: '008080' },

  { token: 'delimiter', foreground: '000000' },
  { token: 'delimiter.html', foreground: '383838' },
  { token: 'delimiter.xml', foreground: '0000FF' },

  { token: 'tag', foreground: '800000' },
  { token: 'tag.css', foreground: '445588', fontStyle: 'bold' }, // added
  { token: 'tag.less', foreground: '445588', fontStyle: 'bold' }, // added
  { token: 'tag.scss', foreground: '445588', fontStyle: 'bold' }, // added
  { token: 'tag.id.jade', foreground: '4F76AC' },
  { token: 'tag.class.jade', foreground: '4F76AC' },
  { token: 'meta.scss', foreground: '800000' },
  { token: 'metatag', foreground: 'e00000' },
  { token: 'metatag.content.html', foreground: 'FF0000' },
  { token: 'metatag.html', foreground: '808080' },
  { token: 'metatag.xml', foreground: '808080' },
  { token: 'metatag.php', fontStyle: 'bold' },

  { token: 'key', foreground: '863B00' },
  { token: 'string.key.json', foreground: 'DD1144' },
  { token: 'string.value.json', foreground: '0451A5' },

  { token: 'attribute.name', foreground: 'FF0000' },
  { token: 'attribute.name.css', foreground: '2E2E2E' }, // added
  { token: 'attribute.name.scss', foreground: '2E2E2E' }, // added
  { token: 'attribute.name.less', foreground: '2E2E2E' }, // added
  { token: 'attribute.value', foreground: '0086B3' }, // changed
  { token: 'attribute.value.number', foreground: '009999' },
  { token: 'attribute.value.unit', foreground: '009999' },
  { token: 'attribute.value.html', foreground: '0000FF' },
  { token: 'attribute.value.xml', foreground: '0000FF' },

  { token: 'string', foreground: 'DD1144' },
  { token: 'string.html', foreground: '0000FF' },
  { token: 'string.sql', foreground: 'FF0000' },
  { token: 'string.yaml', foreground: '0451A5' },

  { token: 'keyword', foreground: '0000FF' },
  { token: 'keyword.json', foreground: '0451A5' },
  { token: 'keyword.flow', foreground: 'AF00DB' },
  { token: 'keyword.flow.scss', foreground: '0000FF' },

  { token: 'operator.scss', foreground: '666666' },
  { token: 'operator.sql', foreground: '778899' },
  { token: 'operator.swift', foreground: '666666' },
  { token: 'predefined.sql', foreground: 'FF00FF' },
];

export default {
  base: 'vs',
  inherit: true,
  rules: [
    ...rules,
    {
      foreground: '999988',
      fontStyle: 'italic',
      token: 'comment',
    },
    {
      foreground: '999999',
      fontStyle: 'bold',
      token: 'comment.block.preprocessor',
    },
    {
      foreground: '999999',
      fontStyle: 'bold italic',
      token: 'comment.documentation',
    },
    {
      foreground: '999999',
      fontStyle: 'bold italic',
      token: 'comment.block.documentation',
    },
    {
      foreground: 'a61717',
      background: 'e3d2d2',
      token: 'invalid.illegal',
    },
    {
      fontStyle: 'bold',
      foreground: '2E2E2E',
      token: 'keyword',
    },
    {
      fontStyle: 'bold',
      token: 'storage',
    },
    {
      fontStyle: 'bold',
      token: 'keyword.operator',
    },
    {
      fontStyle: 'bold',
      token: 'constant.language',
    },
    {
      fontStyle: 'bold',
      token: 'support.constant',
    },
    {
      foreground: '445588',
      fontStyle: 'bold',
      token: 'storage.type',
    },
    {
      foreground: '445588',
      fontStyle: 'bold',
      token: 'support.type',
    },
    {
      foreground: '008080',
      token: 'entity.other.attribute-name',
    },
    {
      foreground: '0086b3',
      token: 'variable.other',
    },
    {
      foreground: '999999',
      token: 'variable.language',
    },
    {
      foreground: '445588',
      fontStyle: 'bold',
      token: 'entity.name.type',
    },
    {
      foreground: '445588',
      fontStyle: 'bold',
      token: 'entity.other.inherited-class',
    },
    {
      foreground: '445588',
      fontStyle: 'bold',
      token: 'support.class',
    },
    {
      foreground: '008080',
      token: 'variable.other.constant',
    },
    {
      foreground: '800080',
      token: 'constant.character.entity',
    },
    {
      foreground: '990000',
      token: 'entity.name.exception',
    },
    {
      foreground: '990000',
      token: 'entity.name.function',
    },
    {
      foreground: '990000',
      token: 'support.function',
    },
    {
      foreground: '990000',
      token: 'keyword.other.name-of-parameter',
    },
    {
      foreground: '555555',
      token: 'entity.name.section',
    },
    {
      foreground: '000080',
      token: 'entity.name.tag',
    },
    {
      foreground: '008080',
      token: 'variable.parameter',
    },
    {
      foreground: '008080',
      token: 'support.variable',
    },
    {
      foreground: '009999',
      token: 'constant.numeric',
    },
    {
      foreground: '009999',
      token: 'constant.other',
    },
    {
      foreground: 'dd1144',
      token: 'string - string source',
    },
    {
      foreground: 'dd1144',
      token: 'constant.character',
    },
    {
      foreground: '009926',
      token: 'string.regexp',
    },
    {
      foreground: '990073',
      token: 'constant.other.symbol',
    },
    {
      fontStyle: 'bold',
      token: 'punctuation',
    },
    {
      foreground: '000000',
      background: 'ffdddd',
      token: 'markup.deleted',
    },
    {
      fontStyle: 'italic',
      token: 'markup.italic',
    },
    {
      foreground: 'aa0000',
      token: 'markup.error',
    },
    {
      foreground: '999999',
      token: 'markup.heading.1',
    },
    {
      foreground: '000000',
      background: 'ddffdd',
      token: 'markup.inserted',
    },
    {
      foreground: '888888',
      token: 'markup.output',
    },
    {
      foreground: '888888',
      token: 'markup.raw',
    },
    {
      foreground: '555555',
      token: 'markup.prompt',
    },
    {
      fontStyle: 'bold',
      token: 'markup.bold',
    },
    {
      foreground: 'aaaaaa',
      token: 'markup.heading',
    },
    {
      foreground: 'aa0000',
      token: 'markup.traceback',
    },
    {
      fontStyle: 'underline',
      token: 'markup.underline',
    },
    {
      foreground: '999999',
      background: 'eaf2f5',
      token: 'meta.diff.range',
    },
    {
      foreground: '999999',
      background: 'eaf2f5',
      token: 'meta.diff.index',
    },
    {
      foreground: '999999',
      background: 'eaf2f5',
      token: 'meta.separator',
    },
    {
      foreground: '999999',
      background: 'ffdddd',
      token: 'meta.diff.header.from-file',
    },
    {
      foreground: '999999',
      background: 'ddffdd',
      token: 'meta.diff.header.to-file',
    },
    {
      foreground: '4183c4',
      token: 'meta.link',
    },
  ],
  colors: {
    'editor.foreground': '#000000',
    'editor.selectionBackground': '#B4D5FE',
    'editor.lineHighlightBackground': '#FFFEEB',
    'editorCursor.foreground': '#666666',
    'editorWhitespace.foreground': '#BBBBBB',

    'editorLineNumber.foreground': '#CCCCCC',
    'diffEditor.insertedTextBackground': '#A0F5B420',
    'diffEditor.removedTextBackground': '#f9d7dc20',
    'editor.selectionBackground': '#aad6f8',
    'editorIndentGuide.activeBackground': '#cccccc',
  },
};
