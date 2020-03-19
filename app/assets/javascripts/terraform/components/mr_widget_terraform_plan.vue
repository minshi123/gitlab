<script>
import ciIcon from '../../vue_shared/components/ci_icon.vue';

export default {
  name: 'MRWidgetTerraformPlan',
  components: {
    ciIcon,
  },
  computed: {
    iconStatusObj() {
      return {
        group: 'warning',
        icon: 'status_warning',
      };
    },
  }
}
</script>
<template>
  <div class="mr-widget-body media">
    <ci-icon :status="iconStatusObj" :size="24" />

    <div class="media-body space-children">
      <p>Terraform plan output the following resources:</p>
      <p>
        <strong>1</strong> to add,
        <strong>0</strong> to change,
        <strong>2</strong> to delete
      </p>
    </div>
    <button
      class="btn btn-default btn-sm"
    >
      View Full Log
    </button>
  </div>
</template>
