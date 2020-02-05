import App from 'ee/vulnerability_management/components/app.vue';
import Vue from 'vue';

window.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('vulnerability-management-app');
  const { vulnerability, vulnerabilityUrl, pipeline, pipelineUrl } = el.dataset;

  // Convert the vulnerability and pipeline JSON into objects and set their respective URLs.
  const vulnerabilityObject = JSON.parse(vulnerability);
  vulnerabilityObject.url = vulnerabilityUrl;
  const pipelineObject = JSON.parse(pipeline);
  pipelineObject.url = pipelineUrl;

  return new Vue({
    el,
    render: createElement =>
      createElement(App, {
        props: { vulnerability: vulnerabilityObject, pipeline: pipelineObject },
      }),
  });
});
