import App from 'ee/vulnerability_management/components/app.vue';
import Vue from 'vue';

window.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('vulnerability-show-header');
  const { createVulnerabilityFeedbackIssuePath } = el.dataset;
  const vulnerability = JSON.parse(el.dataset.vulnerability);
  const finding = JSON.parse(el.dataset.finding);

  return new Vue({
    el,

    render: h =>
      h(App, {
        props: {
          vulnerability,
          finding,
          createVulnerabilityFeedbackIssuePath,
        },
      }),
  });
});
