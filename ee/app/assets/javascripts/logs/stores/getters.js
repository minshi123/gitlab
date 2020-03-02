import dateFormat from 'dateformat';

const mask = 'mmm dd HH:MM:ss.l"Z"';

const mapTrace = ({ timestamp = null, message = '' }) =>
  [timestamp ? dateFormat(timestamp, mask) : '', message].join(' | ');

export const trace = state => state.logs.lines.map(mapTrace).join('\n');

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
