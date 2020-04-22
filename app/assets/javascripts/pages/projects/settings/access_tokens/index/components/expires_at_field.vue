<script>
import { GlDatepicker } from '@gitlab/ui';

export default {
  name: 'ExpiresAtField',
  components: { GlDatepicker },
  data() {
    return {
      date: '',
    };
  },
};
</script>

<template>
  <div>
    <gl-datepicker :target="null" :min-date="new Date()">
      <slot></slot>
    </gl-datepicker>
  </div>
</template>
