<script>
import { GlFormGroup, GlFormInput, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';

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
  data() {
    return {
      fieldBlurs: {
        name: false,
        url: false,
      },
      errors: {
        name: __('Name must be between 1 and 255 characters'),
        url: __(`URL must be a valid url (ex: 'https://gitlab.com')`),
      },
    };
  },
  computed: {
    validName() {
      if (this.fieldBlurs.name && !this.nodeData.name) {
        return false;
      }

      return null;
    },
    validUrl() {
      if (this.fieldBlurs.url && this.checkUrl(this.nodeData.url)) {
        return false;
      }

      return null;
    },
  },
  methods: {
    checkUrl(url) {
      if (!url) {
        return true;
      }

      try {
        new URL(url); // eslint-disable-line no-new
        // valid url
        return false;
      } catch (e) {
        return true;
      }
    },
  },
};
</script>

<template>
  <section class="form-row">
    <gl-form-group
      class="col-sm-6"
      :label="__('Name')"
      label-for="node-name-field"
      :state="validName"
      :invalid-feedback="errors.name"
    >
      <template #description>
        <gl-sprintf
          :message="
            __(
              'The unique identifier for the Geo node. Must match %{geoNodeName} if it is set in gitlab.rb, otherwise it must match %{externalUrl} with a trailing slash',
            )
          "
        >
          <template #geoNodeName>
            <code>{{ __('geo_node_name') }}</code>
          </template>
          <template #externalUrl>
            <code>{{ __('external_url') }}</code>
          </template>
        </gl-sprintf>
      </template>
      <gl-form-input
        id="node-name-field"
        v-model="nodeData.name"
        type="text"
        @blur="fieldBlurs.name = true"
      />
    </gl-form-group>
    <gl-form-group
      class="col-sm-6"
      :label="__('URL')"
      label-for="node-url-field"
      :description="__('The user-facing URL of the Geo node')"
      :state="validUrl"
      :invalid-feedback="errors.url"
    >
      <gl-form-input
        id="node-url-field"
        v-model="nodeData.url"
        type="text"
        @blur="fieldBlurs.url = true"
      />
    </gl-form-group>
  </section>
</template>
