<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import tooltip from '~/vue_shared/directives/tooltip';
import { GlSkeletonLoading } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import IdeTree from './ide_tree.vue';
import ResizablePanel from './resizable_panel.vue';
import RepoCommitSection from './repo_commit_section.vue';
import CommitForm from './commit_sidebar/form.vue';
import IdeReview from './ide_review.vue';
import SuccessMessage from './commit_sidebar/success_message.vue';
import IdeProjectHeader from './ide_project_header.vue';
import $ from 'jquery';

export default {
  components: {
    GlSkeletonLoading,
    ResizablePanel,
    Icon,
    RepoCommitSection,
    IdeTree,
    CommitForm,
    IdeReview,
    SuccessMessage,
    IdeProjectHeader,
  },
  directives: {
    tooltip,
  },
  props: {
    side: {
      type: String,
      required: true,
    },
    tabs: {
      type: Array,
      required: false,
      default: () => [],
    },
    width: {
      type: Number,
      required: true,
    },
  },
  computed: {
    ...mapState(['loading', 'currentActivityView']),
    shownTabs() {
      return this.tabs.filter(tab => tab.show);
    },
    shownTabViews() {
      return _.flatten(this.shownTabs.map(tab => tab.views));
    },
  },
  methods: {
    ...mapActions(['updateActivityBarView']),
    buttonClasses(tab) {
      return [this.isActiveTab(tab) ? 'active' : '', ...(tab.buttonClasses || [])];
    },
    clickTab(e, tab) {
      e.target.blur();

      this.updateActivityBarView(tab.views[0].name);

      // TODO: Is this really needed?  If so, can we avoid using JQuery?
      $(e.currentTarget).tooltip('hide');
    },
    isActiveTab(tab) {
      return tab.views.some(view => this.isActiveView(view.name));
    },
    isActiveView(viewName) {
      // This will be replaced with a mapping to the isActiveView getter when this template is
      // refactored to use collapsible_sidebar.vue
      return this.currentActivityView === viewName;
    },
  },
};
</script>

<template>
  <div
    data-qa-selector="ide_left_sidebar"
    class="ide-sidebar multi-file-commit-panel ide-left-sidebar flex-row-reverse h-100"
  >
    <template v-if="loading">
      <resizable-panel :collapsible="false" :initial-width="width" :min-size="width" :side="side">
        <div class="multi-file-commit-panel-inner">
          <div v-for="n in 3" :key="n" class="multi-file-loading-container">
            <gl-skeleton-loading />
          </div>
        </div>
      </resizable-panel>
    </template>
    <template v-else>
      <resizable-panel
        :collapsible="false"
        :initial-width="width"
        :min-size="width"
        :class="`ide-${side}-sidebar-${currentActivityView}`"
        :side="side"
        class="multi-file-commit-panel-inner"
      >
        <div class="h-100 d-flex flex-column align-items-stretch">
          <div
            v-for="tabView in shownTabViews"
            v-show="isActiveView(tabView.name)"
            :key="tabView.name"
            class="flex-fill js-tab-view min-height-0"
          >
            <component :is="currentActivityView" />
          </div>
          <commit-form />
        </div>
      </resizable-panel>
    </template>
    <nav class="ide-activity-bar">
      <ul class="list-unstyled">
        <li v-for="tab of shownTabs" :key="tab.title">
          <button
            v-tooltip
            :title="tab.title"
            :aria-label="tab.title"
            :class="buttonClasses(tab)"
            data-container="body"
            data-placement="right"
            :data-qa-selector="`${tab.title.toLowerCase()}_tab_button`"
            class="ide-sidebar-link"
            type="button"
            @click="clickTab($event, tab)"
          >
            <icon :size="16" :name="tab.icon" />
          </button>
        </li>
      </ul>
    </nav>
  </div>
</template>
