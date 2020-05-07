import last from 'lodash/last';

export const IMPORT_STATE = {
  FAILED: 'failed',
  FINISHED: 'finished',
  NONE: 'none',
  SCHEDULED: 'scheduled',
  STARTED: 'started',
};

export const isInProgress = state =>
  state === IMPORT_STATE.SCHEDULED || state === IMPORT_STATE.STARTED;

export const calculateJiraImportLabel = jiraImports => {
  const mostRecentJiraProjectKey = last(jiraImports).jiraProjectKey;
  const jiraProjectImportCount = jiraImports.reduce(
    (acc, jiraImport) => (jiraImport.jiraProjectKey === mostRecentJiraProjectKey ? acc + 1 : acc),
    0,
  );
  return `jira-import::${mostRecentJiraProjectKey}-${jiraProjectImportCount}`;
};
