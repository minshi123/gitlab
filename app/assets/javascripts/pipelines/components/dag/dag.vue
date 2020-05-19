<script>
import { GlAlert } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { parseData } from './utils';
import longDAGdata from './longDAGdata.json'
import fabioDAGtwo from './fabioDAGtwo.json'

export default {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  name: 'Dag',
  components: {
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
    };
  },
  computed: {
    shouldDisplayGraph() {
      return !this.showFailureAlert;
    },
  },
  mounted() {
    const { drawGraph, reportFailure } = this;

    console.log(parseData(fabioDAGtwo.stages));

    if (!this.graphUrl) {
      reportFailure();
      return;
    }

    axios
      .get(this.graphUrl)
      .then(response => {
        drawGraph(response.data);
      })
      .catch(reportFailure);
  },
  methods: {
    drawGraph(data) {
      // console.log(parseData(longDAGdata.stages));
      return data;
    },
    hideAlert() {
      this.showFailureAlert = false;
    },
    reportFailure() {
      this.showFailureAlert = true;
    },
  },
};
</script>
<template>
  <div>
    <gl-alert v-if="showFailureAlert" variant="danger" @dismiss="hideAlert">
      {{ __('We are currently unable to fetch data for this graph.') }}
    </gl-alert>
    <div v-if="shouldDisplayGraph" data-testid="dag-graph-container">
      <!-- graph goes here -->
    </div>
  </div>
</template>
