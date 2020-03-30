/**
 * Context: https://gitlab.com/gitlab-org/gitlab/-/issues/198524
 *
 * This feature is pretty unique because not only should it _only_ work on
 * GitLab.com but it also needs to fetch issues _from_ the GitLab project.
 *
 * As far as I can tell, there are no other similar features with these specific
 * requirements. Because this is unique and open to a number of methods of
 * implementation, I decided to encapsulate as much of the logic as possible
 * into single files for easy removal. This is why we're not using Vuex or
 * other such patterns so that the code is easily changed or removed.
 *
 * This file contains the logic for the API request, running locally and
 * processing of the returned issues for easier use in the UI. There are some
 * initial consts which are set to determine behaviour, see below.
 */

import Api from 'ee/api';

// The GitLab URL to check for
const GITLAB_COM = 'gitlab.com';
// The local address for development
const LOCAL = '0.0.0.0';
// The project ID to fetch issues from on GitLab.com
const GITLAB_COM_PROJECT_ID = 278964;
// The local project ID when developing
const LOCAL_PROJECT_ID = 1;
// The label issues are marked with that we want to display
const COMING_SOON_LABEL = 'package::coming-soon';
// The workflow prefix
const WORKFLOW_PREFIX = 'workflow::';
// The accepting contributions label
const ACCEPTING_CONTRIBUTIONS = 'accepting merge requests';

/**
 * Determines if the coming soon feature is enabled in the current environment.
 */
export const isEnabled = () => {
  const { gitlab_url: instanceUrl } = window.gon || {};

  // Only enable the feature if we're on GitLab.com or running locally
  if (instanceUrl.includes(GITLAB_COM) || instanceUrl.includes(LOCAL)) {
    return true;
  }

  return false;
};

/**
 * A small helper function to support building this locally that returns a local
 * projectId if you're running via GDK.
 */
const getProjectId = () => {
  const { gitlab_url: instanceUrl } = window.gon || {};

  if (instanceUrl.includes(LOCAL)) {
    return LOCAL_PROJECT_ID;
  }

  return GITLAB_COM_PROJECT_ID;
};

/**
 * Finds workflow:: scoped labels and returns the first or null.
 * @param {string[]} labels Labels from the issue
 */
const getWorkflowLabel = (labels = []) => {
  const workflowLabels = labels.filter(l => l.name.toLowerCase().includes(WORKFLOW_PREFIX));

  return workflowLabels[0] || null;
};

/**
 * Determines if an issue is accepting community contributions by checking if
 * the "Accepting merge requests" label is present.
 * @param {string[]} labels
 */
const isIssueAcceptingCommunityContributions = (labels = []) =>
  labels.find(l => l.name.toLowerCase() === ACCEPTING_CONTRIBUTIONS) || null;

/**
 * Fetches the issues marked as coming soon for display on the coming soon tab.
 */
export const fetchComingSoonIssues = () => {
  const projectId = getProjectId();

  const params = {
    state: 'opened',
    labels: COMING_SOON_LABEL,
    with_labels_details: 'true',
  };

  return Api.projectIssues(projectId, params).then((issues = []) =>
    issues.map(x => ({
      ...x,
      isAcceptingContributions: isIssueAcceptingCommunityContributions(x.labels),
      workflow: getWorkflowLabel(x.labels),
    })),
  );
};
