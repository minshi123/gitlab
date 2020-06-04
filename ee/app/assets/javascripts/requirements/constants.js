import { __ } from '~/locale';

export const FilterState = {
  opened: 'OPENED',
  archived: 'ARCHIVED',
  all: 'ALL',
};

export const FilterStateEmptyMessage = {
  OPENED: __('There are no open requirements'),
  ARCHIVED: __('There are no archived requirements'),
};

export const TestReportStatus = {
  Passed: 'PASSED',
};

export const DEFAULT_PAGE_SIZE = 20;

export const MAX_TITLE_LENGTH = 255;
