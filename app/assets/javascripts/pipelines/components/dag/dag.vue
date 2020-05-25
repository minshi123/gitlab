<script>
import { GlAlert } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import DagGraph from './dag_graph.vue';
import { PARSE_FAILURE, LOAD_FAILURE, UNSUPPORTED_DATA } from './constants';
import { parseData } from './utils'

import longDAGdata from './longDAGdata.json'
import testDAGdata from './testDAGdata.json'


export default {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  name: 'Dag',
  components: {
    DagGraph,
    GlAlert,
  },
  props: {
    graphUrl: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      showFailureAlert: false,
      failureType: null,
      graphData: null,
    };
  },
  computed: {
    failure() {
      switch (this.failureType) {
        case LOAD_FAILURE:
          return  {
            text: __('We are currently unable to fetch data for this graph.'),
            variant: 'danger',
          };
        case PARSE_FAILURE:
          return  {
            text: __('There was an error parsing the data for this graph.'),
            variant: 'danger',
          };
        case UNSUPPORTED_DATA:
          return {
            text: __('A DAG must have two dependent jobs to be visualized on this tab.'),
            variant: 'info',
          }
        default:
          return  {
            text: __('An unknown error loading this graph ocurred.'),
            vatiant: 'danger',
          };
      }
    },
    shouldDisplayGraph() {
      return Boolean(!this.showFailureAlert && this.graphData);
    },
  },
  mounted() {
    const { processGraphData, reportFailure } = this;

    if (!this.graphUrl) {
      reportFailure();
      return;
    }

    axios
      .get(this.graphUrl)
      .then(response => {
        // processGraphData(response.data);
        processGraphData(testDAGdata);
      })
      .catch(reportFailure.bind(null, LOAD_FAILURE));
  },
  methods: {
    processGraphData(data) {
      let parsed;

      try {
        parsed = parseData(data.stages);
      } catch {
        this.reportFailure(PARSE_FAILURE);
        return;
      }

      if (parsed.links < 2 ) {
        this.reportFailure(UNSUPPORTED_DATA);
        return;
      }

      this.graphData = parsed;
    },
    hideAlert() {
      this.showFailureAlert = false;
    },
    reportFailure(type) {
      this.showFailureAlert = true;
      this.failureType = type;
    },
  },
};
</script>
<template>
  <div>
    <gl-alert v-if="showFailureAlert" :variant="failure.variant" @dismiss="hideAlert">
      {{ failure.text }}
    </gl-alert>
    <dag-graph v-if="shouldDisplayGraph" :graph-data="graphData" @onFailure="reportFailure"></dag-graph>
  </div>
</template>
