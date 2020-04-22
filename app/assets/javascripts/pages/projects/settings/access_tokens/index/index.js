import Vue from 'vue';
import ExpiresAtField from './components/expires_at_field.vue';

document.addEventListener(
  'DOMContentLoaded',
  () =>
    new Vue({
      el: document.querySelector('.js-project-access-tokens-expires-at'),
      components: { ExpiresAtField },
    }),
);
