<script>
import { GlButton, GlFormGroup, GlFormInput } from '@gitlab/ui';
import MarkdownField from '~/vue_shared/components/markdown/field.vue';
import { timeRanges } from '~/vue_shared/constants';
import GroupIterationQuery from '../queries/group_iteration.query.graphql';
import DueDateSelectors from '~/due_date_select';

export default {
  timeRanges,
  components: {
    GlButton,
    GlFormInput,
    MarkdownField,
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
    previewMarkdownPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  // apollo: {
  //   iterations: {
  //     query: GroupIterationQuery,
  //     update: data => data.group.sprints.nodes,
  //     variables() {
  //       return {
  //         fullPath: this.groupPath,
  //         state: this.state,
  //       };
  //     },
  //   },
  // },
  data() {
    return {
      iterations: [],
      loading: 0,
      title: '',
      description: '',
      startDate: '',
      dueDate: null,
    };
  },
  mounted() {
    new DueDateSelectors();
  },
  methods: {
    setStartDate(newDate) {
      this.startDate = newDate;
    },
    setDueDate(newDate) {
      this.dueDate = newDate;
    },
  }
};
</script>

<template>
  <div>
    <div class="d-flex">
      <h3 class="page-title">{{ __('New Iteration') }}</h3>
      <!-- TODO: util classes. canAdminIteration -->
      <!-- <div class="milestone-buttons" v-if="true">
        <gl-button>{{ __('Edit') }}</gl-button>
        <gl-button variant="warning-outline">{{ __('Close iteration') }} </gl-button>
        <gl-button variant="danger">{{ __('Delete') }} </gl-button>
      </div> -->
    </div>
    <hr />
    <section class="row common-note-form">
      <div class="col-sm-6">
        <div class="form-group row">
          <div class="col-sm-2 text-align-right">
            <label for="title">{{ __('Title') }}</label>
          </div>
          <div class="input-group col-sm-10">
            <gl-form-input id="title" v-model="title" />
          </div>
        </div>

        <div class="form-group row">
          <div class="col-form-label col-sm-2">
            <label for="issue-description">{{ __('Description') }}</label>
          </div>
          <div class="col-sm-10">
            <markdown-field
              :markdown-preview-path="previewMarkdownPath"
              :can-attach-file="true"
              :enable-autocomplete="true"
              label="Description"
              :textarea-value="description"
              :add-spacing-class="false"
              markdown-docs-path="/help/user/markdown"
              class="md-area"
            >
              <textarea
                id="issue-description"
                ref="textarea"
                slot="textarea"
                v-model="description"
                class="note-textarea js-gfm-input js-autosize markdown-area"
                dir="auto"
                data-supports-quick-actions="false"
                :aria-label="__('Description')"
              >
              </textarea>
            </markdown-field>
          </div>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-group row">
          <div class="col-form-label col-sm-2">
            <label for="milestone_start_date">{{ __('Start date') }}</label>
          </div>
          <div class="col-sm-10">
            <input
              id="milestone_start_date"
              v-model="startDate"
              class="datepicker form-control"
              :placeholder="__('Select start date')"
              autocomplete="off"
              type="text"
              name="milestone[start_date]"
              @change="setStartDate($event.target.value)"
            />
            <a class="inline float-right prepend-top-5 js-clear-start-date" href="#">{{ __('Clear start date') }}</a>
          </div>
        </div>
        <div class="form-group row">
          <div class="col-form-label col-sm-2">
            <label for="milestone_due_date">{{ __('Due Date') }}</label>
          </div>
          <div class="col-sm-10">
            <input
              id="milestone_due_date"
              class="datepicker form-control"
              :placeholder="__('Select due date')"
              autocomplete="off"
              type="text"
              name="milestone[due_date]"
              @change="setDueDate($event.target.value)"
            />
            <a class="inline float-right prepend-top-5 js-clear-due-date" href="#">{{ __('Clear due date') }}</a>
            <div
              class="pika-single gitlab-theme animate-picker is-hidden is-bound"
              style="position: static; left: auto; top: auto;"
            ></div>
          </div>
        </div>
      </div>
    </section>
    <div class="form-actions">
      <gl-button variant="success">{{ __('Save Iteration') }}</gl-button>
      <gl-button variant="default" class="float-right">{{ __('Cancel') }}</gl-button>
    </div>
  </div>
</template>
