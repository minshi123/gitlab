import { DEFAULT_TIMEOUT, DEFAULT_ALLOWED_IP } from '../constants';

const createState = () => ({
  isLoading: false,
  timeout: DEFAULT_TIMEOUT,
  allowedIp: DEFAULT_ALLOWED_IP,
});
export default createState;
