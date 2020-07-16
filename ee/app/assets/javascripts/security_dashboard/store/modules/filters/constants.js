import { s__ } from '~/locale';

export const ALL = 'all';

export const BASE_FILTERS = {
  severity: {
    externalIds: [],
    name: s__('ciReport|All severities'),
    id: ALL,
  },
  report_type: {
    externalIds: [],
    name: s__('ciReport|All scanners'),
    id: ALL,
  },
  project_id: {
    externalIds: [],
    name: s__('ciReport|All projects'),
    id: ALL,
  },
};
