import Vue from 'vue';
import AuthorSelectApp from './components/author_select.vue';

export default el => {
  if (!el) {
    return null;
  }

  return new Vue({
    el,
    components: {
      AuthorSelectApp,
    },
    render(createElement) {
      return createElement(AuthorSelectApp);
    },
  });
};
