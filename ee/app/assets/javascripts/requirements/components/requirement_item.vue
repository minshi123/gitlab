<script>
import { escape } from 'lodash';
import { GlPopover, GlLink, GlAvatar, GlButton, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { getTimeago } from '~/lib/utils/datetime_utility';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  components: {
    GlPopover,
    GlLink,
    GlAvatar,
    GlButton,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin],
  props: {
    requirement: {
      type: Object,
      required: true,
    },
  },
  computed: {
    reference() {
      return `REQ-${this.requirement.iid}`;
    },
    createdAt() {
      return sprintf(__('opened %{timeAgo}'), {
        timeAgo: escape(getTimeago().format(this.requirement.createdAt)),
      });
    },
    updatedAt() {
      return sprintf(__('updated %{timeAgo}'), {
        timeAgo: escape(getTimeago().format(this.requirement.updatedAt)),
      });
    },
    author() {
      return this.requirement.author;
    },
  },
};
</script>

<template>
  <li>
    <div class="issue-box">
      <div class="issuable-info-container">
        <div class="issuable-main-info">
          <div class="issue-title title">
            <span class="issue-title-text">{{ requirement.title }}</span>
          </div>
          <div class="issuable-info">
            <span class="issuable-reference">{{ reference }}</span>
            <span class="issuable-authored d-none d-sm-inline-block">
              &middot;
              <span
                v-gl-tooltip:tooltipcontainer.bottom
                :title="tooltipTitle(requirement.createdAt)"
              >{{ createdAt }}</span>
              {{ __('by') }}
              <gl-link ref="authorLink" class="author-link js-user-link" :href="author.webUrl">
                <span class="author">{{ author.name }}</span>
              </gl-link>
            </span>
          </div>
        </div>
        <div class="issuable-meta">
          <ul class="controls">
            <li class="requirement-edit d-sm-block">
              <gl-button size="sm" class="p-1">
                <gl-icon name="pencil" :size="16" />
              </gl-button>
            </li>
            <li class="requirement-archive d-sm-block">
              <gl-button size="sm" class="p-1">
                <gl-icon name="archive" :size="16" />
              </gl-button>
            </li>
          </ul>
          <div class="float-right issuable-updated-at d-none d-sm-inline-block">
            <span
              v-gl-tooltip:tooltipcontainer.bottom
              :title="tooltipTitle(requirement.updatedAt)"
            >{{ updatedAt }}</span>
          </div>
        </div>
      </div>
    </div>
    <gl-popover :target="() => $refs.authorLink.$el" triggers="hover focus" placement="top">
      <div class="user-popover p-0 d-flex">
        <div class="p-1 flex-shrink-1">
          <gl-avatar :entity-name="author.name" :alt="author.name" :src="author.avatarUrl" />
        </div>
        <div class="p-1 w-100">
          <h5 class="m-0">{{ author.name }}</h5>
          <div class="text-secondary mb-2">@{{ author.username }}</div>
        </div>
      </div>
    </gl-popover>
  </li>
</template>
