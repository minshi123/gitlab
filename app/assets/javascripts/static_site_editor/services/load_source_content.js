import axios from '~/lib/utils/axios_utils';

const buildAPIUrl = (projectId, sourcePath) => {
  const encodedFilePath = encodeURIComponent(sourcePath);

  return `/api/v4/projects/${projectId}/repository/files/${encodedFilePath}/raw?ref=master`;
};

const extractTitle = content => Array.from(content.match(/title: (.+)\n/i))[1];

const loadSourceContent = ({ projectId, sourcePath }) =>
  axios.get(buildAPIUrl(projectId, sourcePath)).then(({ data }) => ({
    title: extractTitle(data),
    content: data,
  }));

export default loadSourceContent;
