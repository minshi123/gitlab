import { __, sprintf } from '~/locale';
import { numberToHumanSize } from '~/lib/utils/number_utils';

export const BTN_COPY_CONTENTS_TITLE = __('Copy file contents');
export const BTN_RAW_TITLE = __('Open raw');
export const BTN_DOWNLOAD_TITLE = __('Download');

export const SIMPLE_BLOB_VIEWER = 'simple';
export const SIMPLE_BLOB_VIEWER_TITLE = __('Display source');

export const RICH_BLOB_VIEWER = 'rich';
export const RICH_BLOB_VIEWER_TITLE = __('Display rendered file');

export const BLOB_RENDER_ERROR_EVENTS = {
  LOAD: 'force-content-fetch',
  SHOW_SOURCE: 'force-switch-viewer',
};

export const BLOB_RENDER_ERRORS = {
  REASONS: {
    COLLAPSED: {
      id: 'collapsed',
      text: sprintf(__('it is larger than %{limit}'), {
        limit: numberToHumanSize(1048576), // 1MB in bytes
      }),
    },
    TOO_LARGE: {
      id: 'too_large',
      text: sprintf(__('it is larger than %{limit}'), {
        limit: numberToHumanSize(104857600), // 100MB in bytes
      }),
    },
    EXTERNAL: {
      id: 'server_side_but_stored_externally',
      text: {
        lfs: __('it is stored in LFS'),
        build_artifact: __('it is stored as a job artifact'),
        default: __('it is stored externally'),
      },
    },
  },
  OPTIONS: {
    LOAD: {
      text: __('load it anyway'),
      conjunction: __('or'),
      event: BLOB_RENDER_ERROR_EVENTS.LOAD,
    },
    SHOW_SOURCE: {
      text: __('view the source'),
      conjunction: __('or'),
      event: BLOB_RENDER_ERROR_EVENTS.SHOW_SOURCE,
    },
    DOWNLOAD: {
      text: __('download it'),
      conjunction: '',
      target: '_blank',
      condition: true,
    },
  },
};
