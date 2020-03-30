import { fetchComingSoonIssues } from './helpers';
import createFlash from '~/flash';
import ComingSoon from './coming_soon.vue';

export default {
  name: 'ComingSoonLoader',
  components: {
    ComingSoon,
  },
  props: {
    illustration: {
      type: String,
      required: true,
    },
  },
  data() {
    return { issues: [], isLoading: true };
  },
  mounted() {
    fetchComingSoonIssues()
      .then(issues => {
        this.issues = issues;
        this.isLoading = false;
      })
      .catch(ex => createFlash(ex));
  },
  render(h) {
    return h(ComingSoon, {
      props: {
        issues: this.issues,
        isLoading: this.isLoading,
        illustration: this.illustration,
      },
    });
  },
};
