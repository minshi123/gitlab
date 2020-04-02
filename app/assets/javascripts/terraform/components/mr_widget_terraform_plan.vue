<script>
import { __, sprintf } from '~/locale';
import { escape } from 'lodash';
import { GlIcon } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import ciIcon from '../../vue_shared/components/ci_icon.vue';
import createStore from '../store';

export default {
  name: 'MRWidgetTerraformPlan',
  components: {
    ciIcon,
    GlIcon,
  },
  data() {
    return {
      deleteNum: 2,
    };
  },
  computed: {
    ...mapState(['numberToAdd', 'numberToChange']),
    iconStatusObj() {
      return {
        group: 'warning',
        icon: 'status_warning',
      };
    },
    linkText() {
      return __('View full log');
    },
    terraformChangesText() {
      return sprintf(
        __('%{addNum} to add, %{changeNum} to change, %{deleteNum} to delete'),
        {
          addNum: `<strong>${escape(this.numberToAdd)}</strong>`,
          changeNum: `<strong>${escape(this.numberToChange)}</strong>`,
          deleteNum: `<strong>${escape(this.deleteNum)}</strong>`,
        },
        false,
      );
    },
    terraformPlanText() {
      return __('Terraform plan output the following resources:');
    },
  },
  created() {
    this.setEndpoint(this.endpoint)
    this.fetchPlans();
  },
  methods: {
    ...mapActions(['setEndpoint', 'fetchPlans']),
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
  },
  store: createStore(),
};
</script>
<template>
  <section class="mr-widget-section">
    <div class="mr-widget-body media d-flex flex-row">
      <span class="append-right-default align-self-start align-self-lg-center">
        <ci-icon :status="iconStatusObj" :size="24" />
      </span>

      <div class="d-flex flex-fill flex-column flex-md-row">
        <div class="terraform-mr-plan-text normal d-flex flex-column flex-lg-row">
          <p class="m-0 pr-1">{{ terraformPlanText }}</p>
          <p class="m-0" v-html="terraformChangesText"></p>
        </div>

        <div class="terraform-mr-plan-actions">
          <a
            href="#"
            target="_blank"
            data-track-event="click_terraform_mr_plan_button"
            data-track-label="mr_widget_terraform_mr_plan_button"
            data-track-property="terraform_mr_plan_button"
            class="btn btn-sm"
          >
            {{ linkText }}
            <gl-icon name="external-link" />
          </a>
        </div>
      </div>
    </div>
  </section>
</template>
