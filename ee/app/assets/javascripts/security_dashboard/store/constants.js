import { s__ } from '~/locale';

export const SEVERITY_LEVELS = {
  critical: s__('severity|Critical'),
  high: s__('severity|High'),
  medium: s__('severity|Medium'),
  low: s__('severity|Low'),
  unknown: s__('severity|Unknown'),
  info: s__('severity|Info'),
  undefined: s__('severity|Undefined'),
  none: s__('severity|None'),
};

export const CONFIDENCE_LEVELS = {
  confirmed: s__('confidence|Confirmed'),
  high: s__('confidence|High'),
  medium: s__('confidence|Medium'),
  low: s__('confidence|Low'),
  unknown: s__('confidence|Unknown'),
  ignore: s__('confidence|Ignore'),
  experimental: s__('confidence|Experimental'),
  undefined: s__('confidence|Undefined'),
};

export const REPORT_TYPES = {
  container_scanning: s__('ciReport|Container Scanning'),
  dast: s__('ciReport|DAST'),
  dependency_scanning: s__('ciReport|Dependency Scanning'),
  sast: s__('ciReport|SAST'),
};

export const DASHBOARD_TYPES = {
  PROJECT: 'project',
  PIPELINE: 'pipeline',
  GROUP: 'group',
  INSTANCE: 'instance',
};

export const PROJECT_SCANNING_DAY_RANGES = [
  { description: s__('securityDashboard|5 or more days'), minDays: 5, maxDays: 15 },
  { description: s__('securityDashboard|15 or more days'), minDays: 15, maxDays: 30 },
  { description: s__('securityDashboard|30 or more days'), minDays: 30, maxDays: 60 },
  { description: s__('securityDashboard|60 or more days'), minDays: 60, maxDays: Infinity },
];
