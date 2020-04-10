<script>
import { GlToggle } from '@gitlab/ui';

export default {
  name: 'ActiveToggle',
  components: {
    GlToggle,
  },
  props: {
    showActive: {
      type: Boolean,
      required: true,
    },
    initialActivated: {
      type: Boolean,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      activated: this.initialActivated,
    };
  },
  mounted() {
    // Initialize view
    if (this.showActive) {
      this.$nextTick(() => {
        this.onToggle(this.activated);
      });
    }
  },
  methods: {
    onToggle(e) {
      if (this.$root) {
        this.$root.$emit('toggle', e);
      }
    },
  },
};
</script>

<template>
  <div>
    <div v-if="showActive" class="form-group row" role="group">
      <label for="service[active]" class="col-form-label col-sm-2">{{ __('Active') }}</label>
      <div class="col-sm-10 pt-1">
        <gl-toggle
          v-model="activated"
          :disabled="disabled"
          name="service[active]"
          @change="onToggle"
        />
      </div>
    </div>
  </div>
</template>
