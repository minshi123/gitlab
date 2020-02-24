import Vue from 'vue';
import StatusPageSettings from './components/app.vue';
import createStore from './store';

export default () => {
  const formContainerEl = document.querySelector('.js-status-page-form');
  const { enabled, bucketName, region, accessKeyId, secretAccessKey } =  {
    enabled: true,
    bucketName: 'name',
    region: 'US',
    accessKeyId: 'accessKeyId',
    secretAccessKey: 'secretAccessKey',
  };

  return new Vue({
    el: formContainerEl,
    store: createStore(),
    render(createElement) {
      return createElement(StatusPageSettings, {
        props: {
          enabled, bucketName, region, accessKeyId, secretAccessKey,
        },
      });
    },
  });
};
