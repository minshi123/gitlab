<script>
import { SEVERITY_LEVELS } from 'ee/security_dashboard/store/constants';
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';

export const CLASS_NAME_MAP = {
  critical: 'text-danger-800',
  high: 'text-danger-600',
  medium: 'text-warning-400',
  low: 'text-warning-300',
  info: 'text-primary-400',
  unknown: 'text-secondary-400',
};

export const HELP_TEXT_MAP = {
  unknown: __(
    `The rating "unknown" indicates that the underlying scanner doesn’t contain or provide a severity rating.`,
  ),
};

export default {
  name: 'SeverityBadge',
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    severity: {
      type: String,
      required: true,
    },
  },
  computed: {
    hasSeverityBadge() {
      return Object.keys(CLASS_NAME_MAP).includes(this.severityKey);
    },
    severityKey() {
      return this.severity.toLowerCase();
    },
    className() {
      return CLASS_NAME_MAP[this.severityKey];
    },
    iconName() {
      return `severity-${this.severityKey}`;
    },
    severityTitle() {
      return SEVERITY_LEVELS[this.severityKey] || this.severity;
    },
    toolTipTitle() {
      return HELP_TEXT_MAP[this.severityKey] || '';
    },
  },
};
</script>

<template>
  <div v-if="hasSeverityBadge" class="severity-badge text-left text-nowrap gl-text-gray-900">
    <span :class="className"
      ><gl-icon
        v-gl-tooltip
        :title="toolTipTitle"
        :name="iconName"
        :size="12"
        class="append-right-8"
    /></span>
    {{ severityTitle }}
  </div>
</template>
