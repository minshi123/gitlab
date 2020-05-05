/**
 * Helper function to trigger a download.
 *
 * - If the `fileName` is `_blank` it will open the file in a new tab.
 * - If `fileData` is provided, it will inline the content and use data URLs to
 *   download the file. In this case the `url` property will be ignored.
 */
export default ({ fileName, url, fileData }) => {
  let href = url;

  if (fileData) {
    href = `data:text/plain;base64,${fileData}`;
  }

  const anchor = document.createElement('a');
  anchor.download = fileName;
  anchor.href = href;
  anchor.click();
};
