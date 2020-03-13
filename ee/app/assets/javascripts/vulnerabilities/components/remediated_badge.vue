<script>
import { __ } from '~/locale';
import { GlBadge, GlPopover } from '@gitlab/ui';

export default {
  name: 'RemediatedBadge',
  components: {
    GlBadge,
    GlPopover,
  },
  strings: {
    badgeContent: __('Remediated: needs review'),
    popoverTitle: __('Vulnerability remediated. Review before resolving.'),
    popoverContent: __(
      'The vulnerability is no longer detected. Verify the vulnerability has been fixed or removed before changing its status.',
    ),
  },
};
</script>

<template>
  <div class="d-inline-block">
    <gl-badge ref="badge" variant="info">{{ $options.strings.badgeContent }}</gl-badge>
    <gl-popover
      ref="popover"
      :content="$options.strings.popoverContent"
      :target="() => $refs.badge.$el"
      :title="$options.strings.popoverTitle"
      placement="top"
      triggers="hover focus"
    />
  </div>
</template>
