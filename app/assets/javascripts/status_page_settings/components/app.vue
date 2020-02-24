<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import { GlButton, GlSprintf, GlLink, GlFormInput, GlIcon } from '@gitlab/ui';

export default {
  components: { GlButton, GlSprintf, GlLink, GlFormInput, GlIcon },
  props: {
    enabled: {
      type: Boolean,
      required: true,
    },
    bucketName: {
      type: String,
      required: false,
      default: '',
    },
    region: {
      type: String,
      required: false,
      default: '',
    },
    accessKeyId: {
      type: String,
      required: false,
      default: '',
    },
    secretAccessKey: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapGetters([]),
    ...mapState(['enabled']),
  },
  created() {
    this.setInitialState({
      apiHost: this.initialApiHost,
      enabled: this.initialEnabled,
      project: this.initialProject,
      token: this.initialToken,
      listProjectsEndpoint: this.listProjectsEndpoint
    });
  },
  methods: {
    ...mapActions(['setInitialState', 'updateEnabled', 'updateSelectedProject', 'updateSettings']),
    handleSubmit() {
      this.updateSettings();
    },
  },
};
</script>

<template>
  <div>
    <div class="form-check form-group">
      <input
        id="error-tracking-enabled"
        :checked="active"
        class="form-check-input"
        type="checkbox"
        @change="updateEnabled($event.target.checked)"
      />
      <label class="form-check-label" for="error-tracking-enabled">{{
        s__('StatusPage|Active')
        }}</label>
    </div>

    <div class="form-group">
      <label class="label-bold" for="error-tracking-api-host">{{ s__('StatusPage|S3 Bucket name') }}</label>
      <div class="row">
        <div class="col-8 col-md-9 gl-pr-0">
          <!-- eslint-disable @gitlab/vue-i18n/no-bare-attribute-strings -->
          <gl-form-input
            id="status-page-s3-bucket-name "
            :value="bucketName"
            @input="updateBucketName"
          />
          <p class="form-text text-muted">
            <gl-sprintf :message="s__('StatusPage|Bucket %{docsLink}')">
              <template #docsLink>
                <gl-link href="#">
                  <span>{{ s__('StatusPage|configuration documentation.')}}</span>
                  <gl-icon name="external-link" class="vertical-align-middle"/>
                </gl-link>
              </template>
            </gl-sprintf>
          </p>
          <!-- eslint-enable @gitlab/vue-i18n/no-bare-attribute-strings -->
        </div>
      </div>
    </div>

    <div class="form-group">
      <label class="label-bold" for="error-tracking-api-host">{{ s__('StatusPage|AWS Region ') }}</label>
      <div class="row">
        <div class="col-8 col-md-9 gl-pr-0">
          <!-- eslint-disable @gitlab/vue-i18n/no-bare-attribute-strings -->
          <gl-form-input
            id="status-page-aws-region "
            :value="region"
            placeholder="example: us-west-2"
            @input="updateRegion"
          />
          <p class="form-text text-muted">
            <gl-sprintf :message="s__('StatusPage|For help with this configuration, visit %{docsLink}')">
              <template #docsLink>
                <gl-link href="#">
                  <span>{{ s__('StatusPage|AWS documentation.')}}</span>
                  <gl-icon name="external-link" class="vertical-align-middle"/>
                </gl-link>
              </template>
            </gl-sprintf>
          </p>
          <!-- eslint-enable @gitlab/vue-i18n/no-bare-attribute-strings -->
        </div>
      </div>
    </div>

    <gl-button
      :disabled="settingsLoading"
      class="js-error-tracking-button"
      variant="success"
      @click="handleSubmit"
    >
      {{ __('Save changes') }}
    </gl-button>
  </div>
</template>
