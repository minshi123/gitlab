<script>
import { __ } from '~/locale';
import { uniqueId } from 'underscore';
import { GlBadge, GlPopover } from '@gitlab/ui';

export default {
  name: 'RemediatedBadge',
  components: {
    GlBadge,
    GlPopover,
  },
  data: () => ({
    popoverId: uniqueId('remediated_badge_'),
  }),
  strings: {
    badgeContent: __('Remediated: Needs review'),
    popoverTitle: __('Vulnerability remediated. Review before resolving.'),
    popoverContent: __(
      'The vulnerability is no longer detected. Verify the vulnerability has been fixed or removed before changing its status.',
    ),
  },
};
</script>

<template>
  <div class="d-inline-block">
    <gl-badge :id="popoverId" variant="info">{{ $options.strings.badgeContent }}</gl-badge>
    <gl-popover
      :content="$options.strings.popoverContent"
      :target="popoverId"
      :title="$options.strings.popoverTitle"
      placement="top"
      triggers="hover focus"
    />
  </div>
</template>
