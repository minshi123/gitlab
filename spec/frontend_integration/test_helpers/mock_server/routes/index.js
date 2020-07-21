/* eslint-disable global-require */
export default server => {
  [
    require('./graphql'),
    require('./projects'),
    require('./repository'),
    require('./ci'),
    require('./ide'),
    require('./404'),
  ].forEach(({ default: setup }) => {
    setup(server);
  });
};
