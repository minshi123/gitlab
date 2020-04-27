<script>
import { mapState } from 'vuex';

import SavedChangesMessage from '../components/saved_changes_message.vue';

export default {
  components: {
    SavedChangesMessage,
  },
  computed: {
    ...mapState(['savedContentMeta', 'returnUrl']),
  },
};
</script>
<template>
  <div class="container">
    <saved-changes-message
      :branch="savedContentMeta.branch"
      :commit="savedContentMeta.commit"
      :merge-request="savedContentMeta.mergeRequest"
      :return-url="returnUrl"
    />
  </div>
</template>
