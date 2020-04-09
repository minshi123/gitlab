import Api from '~/api';
import { s__ } from '~/locale';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';

import {
  BRANCH_SUFFIX_COUNT,
  DEFAULT_TARGET_BRANCH,
  SUBMIT_CHANGES_BRANCH_ERROR,
  SUBMIT_CHANGES_COMMIT_ERROR,
  SUBMIT_CHANGES_MERGE_REQUEST_ERROR,
} from '../constants';

const placeholderBranchName = (username, targetBranch = DEFAULT_TARGET_BRANCH) =>
  `${username}-${targetBranch}-patch-${`${Date.now()}`.substr(BRANCH_SUFFIX_COUNT)}`;

const createBranch = (projectId, branch) =>
  Api.createBranch(projectId, {
    ref: DEFAULT_TARGET_BRANCH,
    branch,
  }).catch(() => {
    throw new Error(SUBMIT_CHANGES_BRANCH_ERROR);
  });

const commitContent = (projectId, message, branch, sourcePath, content) =>
  Api.commitMultiple(
    projectId,
    convertObjectPropsToSnakeCase({
      branch,
      commitMessage: message,
      actions: [
        convertObjectPropsToSnakeCase({
          action: 'update',
          filePath: sourcePath,
          content,
        }),
      ],
    }),
  ).catch(() => {
    throw new Error(SUBMIT_CHANGES_COMMIT_ERROR);
  });

const createMergeRequest = (projectId, title, sourceBranch, targetBranch = DEFAULT_TARGET_BRANCH) =>
  Api.createProjectMergeRequest(
    projectId,
    convertObjectPropsToSnakeCase({
      title,
      sourceBranch,
      targetBranch,
    }),
  ).catch(() => {
    throw new Error(SUBMIT_CHANGES_MERGE_REQUEST_ERROR);
  });

const submitContentChanges = ({ username, projectId, sourcePath, content }) => {
  const branch = placeholderBranchName(username);
  const mergeRequestTitle = s__(`StaticSiteEditor|Update ${sourcePath} file`);
  const meta = {};

  return createBranch(projectId, branch)
    .then(() => {
      Object.assign(meta, { branch: { label: branch } });

      return commitContent(projectId, mergeRequestTitle, branch, sourcePath, content);
    })
    .then(({ data: { short_id: label, web_url: url } }) => {
      Object.assign(meta, { commit: { label, url } });

      return createMergeRequest(projectId, mergeRequestTitle, branch);
    })
    .then(({ data: { iid: label, web_url: url } }) => {
      Object.assign(meta, { mergeRequest: { label, url } });

      return meta;
    });
};

export default submitContentChanges;
