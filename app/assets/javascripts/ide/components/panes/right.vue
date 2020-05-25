<script>
import { mapGetters, mapState } from 'vuex';
import { __ } from '~/locale';
import CollapsibleSidebar from './collapsible_sidebar.vue';
import { rightSidebarViews } from '../../constants';
import PipelinesList from '../pipelines/list.vue';
import JobsDetail from '../jobs/detail.vue';
import Clientside from '../preview/clientside.vue';
import TerminalView from '../terminal/view.vue';

export default {
  name: 'RightPane',
  components: {
    CollapsibleSidebar,
  },
  computed: {
    ...mapState('terminal', { isTerminalVisible: 'isVisible' }),
    ...mapState(['currentMergeRequestId', 'clientsidePreviewEnabled']),
    ...mapGetters(['packageJson']),
    showLivePreview() {
      return this.packageJson && this.clientsidePreviewEnabled;
    },
    rightExtensionTabs() {
      return [
        {
          show: true,
          title: __('Pipelines'),
          views: [
            { component: PipelinesList, ...rightSidebarViews.pipelines },
            { component: JobsDetail, ...rightSidebarViews.jobsDetail },
          ],
          icon: 'rocket',
        },
        {
          show: this.showLivePreview,
          title: __('Live preview'),
          views: [{ component: Clientside, ...rightSidebarViews.clientSidePreview }],
          icon: 'live-preview',
        },
        {
          show: this.isTerminalVisible,
          title: __('Terminal'),
          views: [{ component: TerminalView, ...rightSidebarViews.terminal }],
          icon: 'terminal',
        },
      ];
    },
  },
};
</script>

<template>
  <collapsible-sidebar :extension-tabs="rightExtensionTabs" side="right" :width="350" />
</template>
