<script>
import { GlTooltipDirective } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import { __, sprintf } from '~/locale';
import { getCommitIconMap } from '~/ide/utils';

export default {
  components: {
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    file: {
      type: Object,
      required: true,
    },
    showTooltip: {
      type: Boolean,
      required: false,
      default: false,
    },
    showStagedIcon: {
      type: Boolean,
      required: false,
      default: true,
    },
    size: {
      type: Number,
      required: false,
      default: 12,
    },
    isCentered: {
      type: Boolean,
      required: false,
      default: true,
    },
    showChangedStatus: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    changedIcon() {
      // False positive i18n lint: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26
      // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
      const suffix = this.showStagedIcon ? '-solid' : '';

      return `${getCommitIconMap(this.file).icon}${suffix}`;
    },
    changedStatus() {
      let status = '';

      if (this.changedIcon.includes('addition')) {
        status = __('Added');
      } else if (this.changedIcon.includes('modified')) {
        status = __('Modified');
      } else if (this.changedIcon.includes('deletion')) {
        status = __('Deleted');
      }

      return status;
    },
    changedIconClass() {
      return `${this.changedIcon} float-left d-block`;
    },
    tooltipTitle() {
      if (!this.showTooltip) return undefined;

      const type = this.file.tempFile ? 'addition' : 'modification';

      if (this.file.changed && !this.file.staged) {
        return sprintf(__('Unstaged %{type}'), {
          type,
        });
      } else if (!this.file.changed && this.file.staged) {
        return sprintf(__('Staged %{type}'), {
          type,
        });
      } else if (this.file.changed && this.file.staged) {
        return sprintf(__('Unstaged and staged %{type}'), {
          type,
        });
      }

      return undefined;
    },
    showIcon() {
      return (
        this.file.changed ||
        this.file.tempFile ||
        this.file.staged ||
        this.file.deleted ||
        this.file.prevPath
      );
    },
  },
};
</script>

<template>
  <span
    v-gl-tooltip.right
    :title="tooltipTitle"
    :class="[{ 'ml-auto': isCentered }, changedIconClass]"
    class="file-changed-icon d-flex align-items-center "
  >
    <icon v-if="showIcon" :name="changedIcon" :size="size" :class="changedIconClass" />
    <span
      v-if="showChangedStatus && changedStatus"
      class="js-changed-status file-changed-status ml-1"
    >
      {{ changedStatus }}
    </span>
  </span>
</template>

<style>
.file-addition,
.file-addition-solid {
  color: #1aaa55;
}

.file-addition > .file-changed-status,
.file-addition-solid > .file-changed-status {
  color: #168f48;
}

.file-modified,
.file-modified-solid {
  color: #fc9403;
}

.file-modified > .file-changed-status,
.file-modified-solid > .file-changed-status {
  color: #de7e00;
}

.file-deletion,
.file-deletion-solid {
  color: #db3b21;
}

.file-deletion > .file-changed-status,
.file-deletion-solid > .file-changed-status {
  color: #c0341d;
}
</style>
