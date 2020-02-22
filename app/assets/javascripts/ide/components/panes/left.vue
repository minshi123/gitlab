<script>
import { s__ } from '~/locale';
import { mapGetters, mapState } from 'vuex';
import { leftSidebarViews } from '../../constants';
import IdeSideBar from '../ide_side_bar.vue';
import IdeTree from '../ide_tree.vue';
import IdeReview from '../ide_review.vue';
import RepoCommitSection from '../repo_commit_section.vue';
import IdeProjectHeader from '../ide_project_header.vue';

export default {
  name: 'LeftPane',
  components: {
    IdeSideBar,
    IdeProjectHeader,
  },
  computed: {
    ...mapState(['loading']),
    ...mapGetters(['currentProject', 'hasChanges']),
    tabs() {
      return [
        {
          show: true,
          title: s__('IDE|Edit'),
          views: [{ component: IdeTree, ...leftSidebarViews.edit }],
          icon: 'code',
          buttonClasses: ['js-ide-edit-mode'],
        },
        {
          show: true,
          title: s__('IDE|Review'),
          views: [{ component: IdeReview, ...leftSidebarViews.review }],
          icon: 'file-modified',
          buttonClasses: ['js-ide-review-mode'],
        },
        {
          show: this.hasChanges,
          title: s__('IDE|Commit'),
          views: [{ component: RepoCommitSection, ...leftSidebarViews.commit }],
          icon: 'commit',
          buttonClasses: ['js-ide-commit-mode', 'qa-commit-mode-tab'],
        },
      ];
    },
  },
};
</script>

<template>
  <div>
    <ide-project-header :project="currentProject" v-if="currentProject" />
    <ide-side-bar :tabs="tabs" :side="'left'" :width="340" />
  </div>
</template>
