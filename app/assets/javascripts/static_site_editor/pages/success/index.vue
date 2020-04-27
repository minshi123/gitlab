<script>
import { mapState } from 'vuex';

import SavedChangesMessage from '../../components/saved_changes_message.vue';

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
  <div class="d-flex justify-content-center">
    <saved-changes-message
      class="w-75"
      :branch="savedContentMeta.branch"
      :commit="savedContentMeta.commit"
      :merge-request="savedContentMeta.mergeRequest"
      :return-url="returnUrl"
    />
  </div>
</template>
