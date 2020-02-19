<script>
import {
  GlAvatar,
  GlTooltipDirective,
  GlIcon,
  GlLink,
  GlSkeletonLoader,
  GlSprintf,
} from '@gitlab/ui';
import { mapGetters, mapState } from 'vuex';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { s__ } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { formatDate } from '~/lib/utils/datetime_utility';

export default {
  name: 'PackageActivity',
  components: {
    ClipboardButton,
    GlAvatar,
    GlIcon,
    GlLink,
    GlSkeletonLoader,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [timeagoMixin],
  computed: {
    ...mapState(['isLoading', 'pipelineError', 'pipelineInfo', 'packageEntity']),
    ...mapGetters(['packageHasPipeline']),
    publishedDate() {
      return formatDate(this.packageEntity.created_at, 'HH:MM yyyy-mm-dd');
    },
    showPipelineInfo() {
      return this.packageHasPipeline && !this.pipelineError;
    },
  },
  i18n: {
    pipelineText: s__(
      'PackageRegistry|Pipeline %{linkStart}%{linkEnd} triggered %{timestamp} by %{author}',
    ),
    publishText: s__('PackageRegistry|Published to the repository at %{timestamp}'),
  },
};
</script>

<template>
  <div class="append-bottom-default">
    <h3 class="gl-font-size-16">{{ __('Activity') }}</h3>

    <div ref="commit-info" class="info-well">
      <div v-if="packageHasPipeline" class="well-segment">
        <gl-skeleton-loader v-if="isLoading" :width="575" :height="10">
          <rect width="300" height="10" rx="2" />
        </gl-skeleton-loader>

        <span v-else-if="pipelineError" ref="pipeline-error">{{ pipelineError }}</span>

        <div v-else class="d-flex align-items-center">
          <gl-icon name="commit" class="append-right-8 d-none d-sm-block" />

          <gl-link :href="`../../commit/${pipelineInfo.sha}`">{{ pipelineInfo.sha }}</gl-link>

          <clipboard-button
            :text="pipelineInfo.sha"
            :title="__('Copy commit SHA')"
            css-class="border-0 text-secondary py-0"
          />
        </div>
      </div>

      <div v-if="showPipelineInfo" ref="pipeline-info" class="well-segment">
        <gl-skeleton-loader v-if="isLoading" :width="575" :height="10">
          <rect width="300" height="10" rx="2" />
        </gl-skeleton-loader>

        <div v-else class="d-flex align-items-center">
          <gl-icon name="pipeline" class="append-right-8 d-none d-sm-block" />

          <gl-sprintf :message="$options.i18n.pipelineText">
            <template #link>
              &nbsp;
              <gl-link :href="pipelineInfo.web_url">#{{ pipelineInfo.id }}</gl-link>
              &nbsp;
            </template>

            <template #timestamp>
              <span v-gl-tooltip :title="tooltipTitle(pipelineInfo.created_at)">
                &nbsp;{{ timeFormatted(pipelineInfo.created_at) }}&nbsp;
              </span>
            </template>

            <template #author
              >{{ pipelineInfo.user.name }}
              <gl-avatar
                class="prepend-left-8 d-none d-sm-block"
                :src="pipelineInfo.user.avatar_url"
                :size="24"
            /></template>
          </gl-sprintf>
        </div>
      </div>

      <div class="well-segment d-flex align-items-center">
        <gl-icon name="clock" class="append-right-8 d-none d-sm-block" />

        <gl-sprintf :message="$options.i18n.publishText">
          <template #timestamp>
            {{ publishedDate }}
          </template>
        </gl-sprintf>
      </div>
    </div>
  </div>
</template>
