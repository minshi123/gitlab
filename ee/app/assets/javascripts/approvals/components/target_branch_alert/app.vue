<script>
import { GlAlert } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';

export default {
  components: {
    GlAlert,
  },
  computed: {
    ...mapState(['pear', 'ghost', 'showAlert']),
  },
  methods: {
    ...mapActions(['closeAlert']),
    hi() {
      console.log('yo');
      this.closeAlert();
      return 'yooo';
      // return this.closeTargetBranchAlert();
    },
  },
};
</script>

<template>
  <div>
    <div @click="hi">Show Alert: {{ showAlert }}</div>
    <gl-alert
      primary-button-text="Charge target branch"
      secondary-button-text="Cancel"
      variant="warning"
      @secondaryAction="closeAlert"
      >{{
        __(
          'Changing target branch will reset the approval rules. Any changes you have made will be lost.',
        )
      }}</gl-alert
    >
  </div>
</template>
