<script>
import { GlFormGroup, GlFormInput, GlSprintf } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { validateName, validateUrl } from '../validations';
import { VALIDATION_FIELD_KEYS, NODE_NAME_MORE_INFO } from '../constants';

export default {
  name: 'GeoNodeFormCore',
  components: {
    GlFormGroup,
    GlFormInput,
    GlSprintf,
  },
  props: {
    nodeData: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapState(['formErrors']),
  },
  methods: {
    ...mapActions(['setError']),
    checkName() {
      this.setError({ key: VALIDATION_FIELD_KEYS.NAME, error: validateName(this.nodeData.name) });
    },
    checkUrl() {
      this.setError({ key: VALIDATION_FIELD_KEYS.URL, error: validateUrl(this.nodeData.url) });
    },
  },
  NODE_NAME_MORE_INFO,
};
</script>

<template>
  <section>
    <gl-form-group
      class="mr-sm-3"
      :label="__('Name')"
      label-for="node-name-field"
      :state="Boolean(formErrors.name)"
      :invalid-feedback="formErrors.name"
    >
      <template #description>
        <gl-sprintf
          :message="
            __('Must match with the %{geoNodeName} in /etc/gitlab/gitlab.rb %{moreInformation}')
          "
        >
          <template #geoNodeName>
            <code>{{ __('geo_node_name') }}</code>
          </template>
          <template #moreInformation>
            <a :href="$options.NODE_NAME_MORE_INFO" target="_blank">{{ __('More information') }}</a>
          </template>
        </gl-sprintf>
      </template>
      <gl-form-input
        id="node-name-field"
        v-model="nodeData.name"
        class="gl-w-half"
        :class="{ 'is-invalid': Boolean(formErrors.name) }"
        data-qa-selector="node_name_field"
        type="text"
        @input="checkName"
      />
    </gl-form-group>
    <section class="gl-display-sm-flex gl-align-items-start">
      <gl-form-group
        class="gl-flex-fill-1 mr-sm-3"
        :label="__('URL')"
        label-for="node-url-field"
        :state="Boolean(formErrors.url)"
        :invalid-feedback="formErrors.url"
      >
        <template #description>
          <gl-sprintf :message="__('Must match with the %{externalUrl} in /etc/gitlab/gitlab.rb')">
            <template #externalUrl>
              <code>{{ __('external_url') }}</code>
            </template>
          </gl-sprintf>
        </template>
        <gl-form-input
          id="node-url-field"
          v-model="nodeData.url"
          :class="{ 'is-invalid': Boolean(formErrors.url), 'gl-w-half': !nodeData.primary }"
          data-qa-selector="node_url_field"
          type="text"
          @input="checkUrl"
        />
      </gl-form-group>
      <gl-form-group
        v-if="nodeData.primary"
        class="gl-flex-fill-1"
        :label="__('Internal URL (optional)')"
        label-for="node-internal-url-field"
        :description="
          __('The URL defined on the primary node that secondary nodes should use to contact it')
        "
      >
        <gl-form-input id="node-internal-url-field" v-model="nodeData.internalUrl" type="text" />
      </gl-form-group>
    </section>
  </section>
</template>
