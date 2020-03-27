<script>
import { GlToggle } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlToggle
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
      activated: this.initialActivated
    }
  }
}
</script>

<template>
  <div>
    <div v-if="showActive" class="form-group row" role="group">
      <label for="service_active" class="col-form-label col-sm-2">{{ __('Active') }}</label>
      <div class="col-sm-10 pt-1">
        <gl-toggle v-model="activated" :disabled="disabled" />
        <input id="service_active" type="hidden" name="service[active]" :value="activated" />
      </div>
    </div>
  </div>
</template>
