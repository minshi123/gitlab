<script>
  import {
    GlButton,
    GlTabs,
    GlTab,
  } from '@gitlab/ui';
  import AlertsSettingsForm from './alerts_form.vue';
  import {__, s__} from '~/locale';

  export default {
    props: {
      operationsSettingsEndpoint: {
        type: String,
        required: true,
      },
      alertSettings: {
        type: Object,
        required: true,
      },
    },
    components: {
      GlButton,
      GlTabs,
      GlTab,
      AlertsSettingsForm,
    },
    tabs: [{
      title: s__('IncidentSettings|Alert integration'),
      component: 'AlertsSettingsForm',
      active: true,
      settings: 'alertSettings',
    },
      {
        title: s__('IncidentSettings|Pager Duty integration'),
        component: '',
        active: true,
        setting:  '',
      },
      {
        title: s__('IncidentSettings|Grafana integration'),
        component: '',
        active: true,
        settings: ''
      }],
    i18n: {
      headerText: s__('IncidentSettings|Incidents'),
      expandBtnLabel: __('Expand'),
      saveBtnLabel: __('Save changes'),
      subHeaderText: s__(
        'IncidentSettings|Set up integration with external tools to help better manage incidents.',
      )
    },
    methods: {
      getSettings(settingsProp) {
        return this[settingsProp];
      },
    }
  };
</script>

<template>
  <section id="incident-management-settings" class="settings no-animate js-incident-management-settings">
    <div class="settings-header">
      <h3 ref="sectionHeader" class="h4">
        {{ $options.i18n.headerText }}
      </h3>
      <gl-button ref="toggleBtn" class="js-settings-toggle">{{ $options.i18n.expandBtnLabel }}</gl-button>
      <p ref="sectionSubHeader">
        {{ $options.i18n.subHeaderText }}
      </p>
    </div>

    <div class="settings-content">
      <gl-tabs>
        <gl-tab v-for="tab in $options.tabs" v-if="tab.active" :title="tab.title">
          <component :is="tab.component"
                     :settings="getSettings(tab.settings)"
                     :form-submit-endpoint="operationsSettingsEndpoint"/>
        </gl-tab>
      </gl-tabs>
    </div>
  </section>
</template>
