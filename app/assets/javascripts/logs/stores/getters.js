import { formatDate } from '../utils';

const mapTrace = ({ timestamp = null, pod = '', message = '' }) =>
  [timestamp ? formatDate(timestamp) : '', pod, message].join(' | ');

export const trace = state => state.logs.lines.map(mapTrace).join('\n');

export const showAdvancedFilters = state => {
  // return false;

  const environment = state.environments.options.find(
    ({ name }) => name === state.environments.current,
  );
  return environment && environment.enable_advanced_logs_querying;
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
