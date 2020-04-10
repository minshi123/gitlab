<script>
import { GlFormCheckbox, GlFormRadio } from '@gitlab/ui';

export default {
  name: 'JiraTriggerFields',
  components: {
    GlFormCheckbox,
    GlFormRadio,
  },
  props: {
    initialTriggerCommit: {
      type: Boolean,
      required: true,
    },
    initialTriggerMergeRequest: {
      type: Boolean,
      required: true,
    },
    initialEnableComments: {
      type: Boolean,
      required: true,
    },
    initialCommentDetail: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      triggerCommit: this.initialTriggerCommit,
      triggerMergeRequest: this.initialTriggerMergeRequest,
      enableComments: this.initialEnableComments,
      commentDetail: this.initialCommentDetail,
    };
  },
};
</script>

<template>
  <div class="form-group row" role="group">
    <label for="service[trigger]" class="col-form-label col-sm-2">{{ __('Trigger') }}</label>
    <div class="col-sm-10 pt-1">
      <p>
        {{
          s__(
            'Integrations|When a Jira issue is mentioned in a commit or merge request a remote link and comment (if enabled) will be created.',
          )
        }}
      </p>

      <input name="service[commit_events]" type="hidden" value="false" />
      <gl-form-checkbox v-model="triggerCommit" name="service[commit_events]">
        {{ __('Commit') }}
      </gl-form-checkbox>

      <input name="service[merge_requests_events]" type="hidden" value="false" />
      <gl-form-checkbox v-model="triggerMergeRequest" name="service[merge_requests_events]">
        {{ __('Merge request') }}
      </gl-form-checkbox>

      <div v-show="triggerCommit || triggerMergeRequest">
        <p>
          <strong>{{ s__('Integrations|Comment settings:') }}</strong>
        </p>
        <input name="service[comment_on_event_enabled]" type="hidden" value="false" />
        <gl-form-checkbox v-model="enableComments" name="service[comment_on_event_enabled]">
          {{ s__('Integrations|Enable comments') }}
        </gl-form-checkbox>

        <div v-show="enableComments">
          <p>
            <strong>{{ s__('Integrations|Comment detail:') }}</strong>
          </p>
          <gl-form-radio v-model="commentDetail" value="standard" name="service[comment_detail]">
            {{ s__('Integrations|Standard') }}
            <template #help>
              {{ s__('Integrations|Includes commit title and branch') }}
            </template>
          </gl-form-radio>
          <gl-form-radio v-model="commentDetail" value="all_details" name="service[comment_detail]">
            {{ s__('Integrations|All details') }}
            <template #help>
              {{
                s__(
                  'Integrations|Includes Standard plus entire commit message, commit hash, and issue IDs',
                )
              }}
            </template>
          </gl-form-radio>
        </div>
      </div>
    </div>
  </div>
</template>
