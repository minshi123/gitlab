<script>
import { mapActions, mapState } from 'vuex';
import { GlAlert } from '@gitlab/ui';

import { FETCH_SETTINGS_ERROR_MESSAGE } from '../constants';

import SettingsForm from './settings_form.vue';

export default {
  components: {
    SettingsForm,
    GlAlert,
  },
  computed: {
    ...mapState(['isDisabled']),
  },
  mounted() {
    this.fetchSettings().catch(() =>
      this.$toast.show(FETCH_SETTINGS_ERROR_MESSAGE, { type: 'error' }),
    );
  },
  methods: {
    ...mapActions(['fetchSettings']),
  },
};
</script>

<template>
  <div>
    <p>
      {{ s__('ContainerRegistry|Tag expiration policy is designed to:') }}
    </p>
    <ul>
      <li>{{ s__('ContainerRegistry|Keep and protect the images that matter most.') }}</li>
      <li>
        {{
          s__(
            "ContainerRegistry|Automatically remove extra images that aren't designed to be kept.",
          )
        }}
      </li>
    </ul>
    <settings-form v-if="!isDisabled" ref="settings-form" />
    <gl-alert v-else ref="alert" :dismissible="false">
      {{
        __(
          'Currently, the Container Registry tag expiration feature is not available for projects created before GitLab version 12.8.',
        )
      }}
    </gl-alert>
  </div>
</template>
