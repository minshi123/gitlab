import Vue from 'vue';
import createRouter from 'ee/security_dashboard/store/router';
import syncWithRouter from 'ee/security_dashboard/store/plugins/sync_with_router';
import createStore from 'ee/security_dashboard/store';
import SecurityReportApp from 'ee/vue_shared/security_reports/card_security_reports_app.vue';
import FirstClassDashboard from 'ee/security_dashboard/components/first_class_dashboard.vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import createDefaultClient from '~/lib/graphql';
import VueApollo from 'vue-apollo';

let render;

if (gon?.features?.firstClassVulnerabilities) {
  Vue.use(VueApollo);

  render = el => {
    if (!el) {
      return false;
    }

    const { dashboardDocumentation, emptyStateSvgPath, projectFullPath } = el.dataset;

    const apolloProvider = new VueApollo({
      defaultClient: createDefaultClient(),
    });

    return new Vue({
      el,
      apolloProvider,
      render(createElement) {
        return createElement(FirstClassDashboard, {
          props: {
            emptyStateSvgPath,
            dashboardDocumentation,
            projectFullPath,
          },
        });
      },
    });
  };
} else {
  render = el => {
    const {
      hasPipelineData,
      userPath,
      userAvatarPath,
      pipelineCreated,
      pipelinePath,
      userName,
      commitId,
      commitPath,
      refId,
      refPath,
      pipelineId,
      projectId,
      projectName,
      dashboardDocumentation,
      emptyStateSvgPath,
      vulnerabilitiesEndpoint,
      vulnerabilitiesSummaryEndpoint,
      vulnerabilityFeedbackHelpPath,
      securityDashboardHelpPath,
      emptyStateIllustrationPath,
    } = el.dataset;

    const parsedPipelineId = parseInt(pipelineId, 10);
    const parsedHasPipelineData = parseBoolean(hasPipelineData);

    let props = {
      hasPipelineData: parsedHasPipelineData,
      dashboardDocumentation,
      emptyStateSvgPath,
      vulnerabilitiesEndpoint,
      vulnerabilitiesSummaryEndpoint,
      vulnerabilityFeedbackHelpPath,
      securityDashboardHelpPath,
      emptyStateIllustrationPath,
    };
    if (parsedHasPipelineData) {
      props = {
        ...props,
        project: {
          id: projectId,
          name: projectName,
        },
        triggeredBy: {
          avatarPath: userAvatarPath,
          name: userName,
          path: userPath,
        },
        pipeline: {
          id: parsedPipelineId,
          created: pipelineCreated,
          path: pipelinePath,
        },
        commit: {
          id: commitId,
          path: commitPath,
        },
        branch: {
          id: refId,
          path: refPath,
        },
      };
    }

    const router = createRouter();
    const store = createStore({ plugins: [syncWithRouter(router)] });

    return new Vue({
      el,
      store,
      router,
      components: {
        SecurityReportApp,
      },
      render(createElement) {
        return createElement('security-report-app', {
          props,
        });
      },
    });
  };
}

document.addEventListener('DOMContentLoaded', () => {
  render(document.getElementById('js-security-report-app'));
});
