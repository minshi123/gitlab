import Vue from 'vue';
import ProjectPipelinesCharts from './components/app.vue';

export default () => {
  const el = document.querySelector('#js-project-pipelines-charts-app');

  return new Vue({
    el,
    name: 'ProjectPipelinesChartsApp',
    components: {
      ProjectPipelinesCharts,
    },
    render: createElement => createElement(ProjectPipelinesCharts, {}),
  });
};
