<script>
import axios from '~/lib/utils/axios_utils';

export default {
  name: 'Dag',
  props: {
    graphUrl: {
      type: String,
      required: false,
      default: '/root/auto-stop-env-test/pipelines/90/dag'
    }
  },
  mounted() {
    const drawGraph = this.drawGraph;

    axios.get(this.graphUrl)
      .then(function (response) {
        console.log(response);
        // const {
        //   details: { stages: simplified },
        // } = mockDAGdata;
        //
        // const {
        //   details: { stages: stages },
        // } = gitlabDAGdata;
        //
        // const {
        //   details: { stages: nestedStages },
        // } = groupDAGdata;
        //
        // const {
        //   stages: endpointStages,
        // } = response.data;

      })
      .catch(function (error) {
        console.log(error);
      });
  },
  methods: {
    drawGraph(data) {
      return data;
    },
  },
};

</script>
<template>
  <div>
    hi
  </div>
</template>
