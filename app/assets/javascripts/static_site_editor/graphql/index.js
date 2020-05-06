import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import typeDefs from './typedefs.graphql';

import fileResolver from './resolvers/file';

Vue.use(VueApollo);

const createApolloProvider = data => {
  const defaultClient = createDefaultClient(
    {
      Project: {
        file: fileResolver,
      },
    },
    {
      typeDefs,
    },
  );

  defaultClient.cache.writeData({
    data,
  });

  return new VueApollo({
    defaultClient,
  });
};

export default createApolloProvider;
