/* eslint-disable @gitlab/require-i18n-strings */
import { __, s__ } from '~/locale';

import { STATUS_FAILED, STATUS_NEUTRAL, STATUS_SUCCESS } from '~/reports/constants';

/*
 * Endpoint still returns 'approved' & 'blacklisted'
 * even though we adopted 'allowed' & 'denied' in the UI
 */
export const LICENSE_APPROVAL_STATUS = {
  ALLOWED: 'approved',
  DENIED: 'blacklisted',
};

export const LICENSE_APPROVAL_ACTION = {
  ALLOW: 'allow',
  DENY: 'deny',
};

export const KNOWN_LICENSES = [
  'AGPL-1.0',
  'AGPL-3.0',
  'Apache 2.0',
  'Artistic-2.0',
  'BSD',
  'CC0 1.0 Universal',
  'CDDL-1.0',
  'CDDL-1.1',
  'EPL-1.0',
  'EPL-2.0',
  'GPLv2',
  'GPLv3',
  'ISC',
  'LGPL',
  'LGPL-2.1',
  'MIT',
  'Mozilla Public License 2.0',
  'MS-PL',
  'MS-RL',
  'New BSD',
  'Python Software Foundation License',
  'ruby',
  'Simplified BSD',
  'WTFPL',
  'Zlib',
];

export const REPORT_HEADERS = {
  [STATUS_FAILED]: {
    main: s__('LicenseManagement|Denied'),
    subtext: __("Out-of-compliance with this project's policies and should be removed"),
  },
  [STATUS_SUCCESS]: {
    main: s__('LicenseManagement|Allowed'),
    subtext: __('Acceptable for use in this project'),
  },
  [STATUS_NEUTRAL]: {
    main: s__('LicenseManagement|Uncategorized'),
    subtext: __('No policy matches this license'),
  },
};
