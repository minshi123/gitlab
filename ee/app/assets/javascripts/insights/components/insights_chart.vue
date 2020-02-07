<script>
import { GlColumnChart, GlLineChart, GlStackedColumnChart } from '@gitlab/ui/dist/charts';
import { getSvgIconPathContent } from '~/lib/utils/icon_utils';
import ResizableChartContainer from '~/vue_shared/components/resizable_chart/resizable_chart_container.vue';
import InsightsChartError from './insights_chart_error.vue';

const CHART_HEIGHT = 300;

export default {
  components: {
    GlColumnChart,
    GlLineChart,
    GlStackedColumnChart,
    ResizableChartContainer,
    InsightsChartError,
  },
  props: {
    loaded: {
      type: Boolean,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: false,
      default: '',
    },
    data: {
      type: Object,
      required: true,
    },
    error: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      svgs: {},
    };
  },
  computed: {
    dataZoomConfig() {
      const handleIcon = this.svgs['scroll-handle'];

      return handleIcon ? { handleIcon } : {};
    },
    chartOptions() {
      let options = {};

      if (this.type === 'line') {
        options = {
          xAxis: {
            name: this.data.xAxisTitle,
            type: 'category',
          },
          yAxis: {
            name: this.data.yAxisTitle,
            type: 'value',
          },
        };
      }

      return { dataZoom: [this.dataZoomConfig], ...options };
    },
  },
  methods: {
    setSvg(name) {
      return getSvgIconPathContent(name)
        .then(path => {
          if (path) {
            this.$set(this.svgs, name, `path://${path}`);
          }
        })
        .catch(e => {
          // eslint-disable-next-line no-console, @gitlab/i18n/no-non-i18n-strings
          console.error('SVG could not be rendered correctly: ', e);
        });
    },
    onChartCreated() {
      this.setSvg('scroll-handle');
    },
  },
  height: CHART_HEIGHT,
};
</script>
<template>
  <resizable-chart-container v-if="loaded" class="insights-chart">
    <h5 class="text-center">{{ title }}</h5>
    <gl-column-chart
      v-if="type === 'bar'"
      v-bind="$attrs"
      :height="$options.height"
      :data="data.datasets"
      :x-axis-type="__('category')"
      :x-axis-title="data.xAxisTitle"
      :y-axis-title="data.yAxisTitle"
      :option="chartOptions"
      @created="onChartCreated"
    />
    <gl-stacked-column-chart
      v-else-if="type === 'stacked-bar'"
      v-bind="$attrs"
      :height="$options.height"
      :data="data.datasets"
      :group-by="data.labels"
      :series-names="data.labels"
      :x-axis-type="__('category')"
      :x-axis-title="data.xAxisTitle"
      :y-axis-title="data.yAxisTitle"
      :option="chartOptions"
      @created="onChartCreated"
    />
    <gl-line-chart
      v-else-if="type === 'line'"
      v-bind="$attrs"
      :height="$options.height"
      :data="data.datasets"
      :option="chartOptions"
      @created="onChartCreated"
    />
  </resizable-chart-container>
  <insights-chart-error
    v-else
    :chart-name="title"
    :title="__('This chart could not be displayed')"
    :summary="__('Please check the configuration file for this chart')"
    :error="error"
  />
</template>
