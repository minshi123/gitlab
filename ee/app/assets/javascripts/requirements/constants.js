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

export const AvailableSortOptions = [
  {
    id: 1,
    title: __('Created date'),
    sortDirection: {
      descending: 'created_desc',
      ascending: 'created_asc',
    },
  },
  {
    id: 2,
    title: __('Last updated'),
    sortDirection: {
      descending: 'updated_desc',
      ascending: 'updated_asc',
    },
  },
];

export const DEFAULT_PAGE_SIZE = 20;

export const MAX_TITLE_LENGTH = 255;
