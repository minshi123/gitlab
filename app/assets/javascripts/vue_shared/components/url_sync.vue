<script>
import { historyPushState } from '~/lib/utils/common_utils';
import { setUrlParams } from '~/lib/utils/url_utility';

export default {
  props: {
    query: {
      type: String,
      required: true
    }
  },
  watch: {
    query: {
      deep: true,
      handler() {
        historyPushState(setUrlParams(this.query, window.location.href, true));
      }
    },
  },
};
</script>