import { DEFAULT_TIMEOUT, DEFAULT_ALLOWED_IP, VALIDATION_FIELD_KEYS } from '../constants';

export default () => ({
  isLoading: false,
  timeout: DEFAULT_TIMEOUT,
  allowedIp: DEFAULT_ALLOWED_IP,
  formErrors: Object.values(VALIDATION_FIELD_KEYS).reduce(
    (acc, cur) => ({ ...acc, [cur]: '' }),
    {},
  ),
});
