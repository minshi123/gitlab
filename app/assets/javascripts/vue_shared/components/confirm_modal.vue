<script>
import { GlModal } from '@gitlab/ui';
import CSRF from '~/lib/utils/csrf';

export default {
  components: {
    GlModal,
  },
  mounted() {
    this.$refs[this.$attrs.modalId].show();
  },
  methods: {
    submit() {
      this.$refs.form.requestSubmit();
    },
  },
  CSRF,
};
</script>

<template>
  <gl-modal :ref="$attrs.modalId" v-bind="$attrs" @primary="submit">
    <form ref="form" :action="$attrs.path" method="post">
      <input type="hidden" name="_method" :value="$attrs.method" />
      <input type="hidden" name="authenticity_token" :value="$options.CSRF.token" />
      <div>{{ $attrs.message }}</div>
    </form>
  </gl-modal>
</template>
