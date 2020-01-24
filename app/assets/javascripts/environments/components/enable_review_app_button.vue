<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import ModalCopyButton from '~/vue_shared/components/modal_copy_button.vue';
import { s__, sprintf } from '~/locale';

export default {
  components: {
    GlButton,
    GlModal,
    ModalCopyButton,
  },
  directives: {
    'gl-modal': GlModalDirective,
  },
  props: {
    appMetadata: {
      type: Object,
      default: (() => ({
        sourceProjectId: '100',
        sourceProjectPath: '',
        mergeRequestId: 10,
        appUrl: '',
      }))
    },
    cssClass: {
      type: String,
      required: false,
      default: '',
    },
    link: {
      type: String,
      // required: true,
      default: 'www.example.com'
    },
  },
  computed: {
    instructionText() {
      return {
        step1: sprintf(
          s__('EnableReviewApp|%{stepStart}Step 1%{stepEnd}. Ensure you have Kubernetes set up and have a base domain for your %{linkStart}cluster%{linkEnd}.'),
          {
            stepStart: '<strong>',
            stepEnd: '</strong>',
            linkStart:
              '<a href="https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html">',
            linkEnd: '</a>',
          },
          false,
        ),
        step2: sprintf(
          s__(
            'EnableReviewApp|%{stepStart}Step 2%{stepEnd}. Copy the following snippet:',
          ),
          {
            stepStart: '<strong>',
            stepEnd: '</strong>',
          },
          false,
        ),
        step3: sprintf(
          s__(
            `EnableReviewApp|%{stepStart}Step 3%{stepEnd}. Add it to the project %{linkStart}gitlab-ci.yml%{linkEnd} file.`,
          ),
          {
            stepStart: '<strong>',
            stepEnd: '</strong>',
            linkStart:
              '<a href="blob/master/.gitlab-ci.yml">',
            linkEnd: '</a>',
            mrId: this.appMetadata.mergeRequestId,
          },
          false,
        ),
      };
    },
  },
  modalInfo: {
    closeText: s__('EnableReviewApp|Close'),
    copyToClipboardText: s__('EnableReviewApp|Copy snippet text'),
    copyString: `deploy_review
  stage: deploy
  script:
    - echo \"Deploy a review app\",
  environment:
    name: review/$CI_COMMIT_REF_NAME
    url: https://$CI_ENVIRONMENT_SLUG.example.com
  only: branches
  except: master`,
    id: 'enable-review-app-info',
    title: s__('ReviewApp|Enable Review App'),
  },
};
</script>
<template>
  <div>
    <gl-button
      v-gl-modal="$options.modalInfo.id"
      variant="outline-info"
      type="button"
    >
      {{ s__('Environments|Enable review app') }}
    </gl-button>
    <gl-modal
      :modal-id="$options.modalInfo.id"
      :title="$options.modalInfo.title"
      size="lg"
      class="text-2 ws-normal"
      ok-only
      ok-variant="light"
      :ok-title="$options.modalInfo.closeText"
    >
      <p v-html="instructionText.step1"></p>
      <div>
        <p v-html="instructionText.step2"></p>
        <div class="flex align-items-start">
          <pre class="w-100"> {{ $options.modalInfo.copyString }} </pre>
          <modal-copy-button
            :title="$options.modalInfo.copyToClipboardText"
            :text="$options.modalInfo.copyString"
            :modal-id="$options.modalInfo.id"
            css-classes="border-0"
          />
        </div>
      </div>
      <p v-html="instructionText.step3"></p>
      <template #modal-cancel> Close </template>
    </gl-modal>
  </div>
</template>
