export const isContentLoaded = ({ content }) => Boolean(content);
export const contentChanged = ({ originalContent, content }) => originalContent !== content;
