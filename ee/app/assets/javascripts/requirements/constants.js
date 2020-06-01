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

export const SortOptions = {
  CreatedDescending: 'created_desc',
  CreatedAscending: 'created_asc',
  UpdatedDescending: 'updated_desc',
  UpdatedAscending: 'updated_asc',
};

export const DEFAULT_PAGE_SIZE = 20;

export const MAX_TITLE_LENGTH = 255;
