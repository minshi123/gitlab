<script>
import { GlSprintf, GlLink } from '@gitlab/ui';

export default {
  name: 'VulnerabilityDetails',
  components: { GlSprintf, GlLink },
  props: {
    vulnerability: {
      type: Object,
      required: true,
    },
    finding: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <div class="issuable-details">
    <h2 class="title">{{ vulnerability.title }}</h2>
    <div class="md">
      <h3>{{ __('Description') }}</h3>
      <p>{{ finding.description }}</p>
      <ul>
        <li>
          <gl-sprintf :message="__('Severity: %{severity}')">
            <template #severity>{{ vulnerability.severity }}</template>
          </gl-sprintf>
        </li>
        <li>
          <gl-sprintf :message="__('Confidence: %{confidence}')">
            <template #confidence>{{ vulnerability.confidence }}</template>
          </gl-sprintf>
        </li>
        <li>
          <gl-sprintf :message="__('Report Type: %{reportType}')">
            <template #reportType>{{ vulnerability.report_type }}</template>
          </gl-sprintf>
        </li>

        <li v-if="finding.location.image">
          <gl-sprintf :message="__('Image: %{image}')">
            <template #image>{{ finding.location.image }}</template>
          </gl-sprintf>
        </li>

        <li v-if="finding.location.operating_system">
          <gl-sprintf :message="__('Namespace: %{namespace}')">
            <template #namespace>{{ finding.location.operating_system }}</template>
          </gl-sprintf>
        </li>

        <template v-if="finding.location.file">
          <h3>{{ __('Location') }}</h3>
          <ul>
            <li>{{ __('File:') }} PLACEHOLDER</li>
            <li v-if="finding.location.class">{{ __('Class:') }} {{ finding.location.class }}</li>
            <li v-if="finding.location.method">
              {{ __('Method:') }} {{ finding.location.method }}
            </li>
          </ul>
        </template>

        <template v-if="finding.links.length">
          <h3>{{ __('Links') }}</h3>
          <ul>
            <li v-for="link in finding.links" :key="link.url">
              <gl-link
                :href="link.url"
                target="_blank"
                :aria-label="__('Third Party Advisory Link')"
                :title="link.url"
              >
                {{ link.url }}
              </gl-link>
            </li>
          </ul>
        </template>

        <template v-if="finding.identifiers.length">
          <h3>{{ __('Identifiers') }}</h3>
          <ul>
            <li v-for="identifier in finding.identifiers" :key="identifier.url">
              <gl-link :href="identifier.url" target="_blank">{{ identifier.name }}</gl-link>
            </li>
          </ul>
        </template>
      </ul>
    </div>
  </div>
</template>
