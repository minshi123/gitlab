<script>
import { __ } from '~/locale';
import { GlTabs, GlTab } from '@gitlab/ui';

// SET projects[] <- data from response
// INITIALISE untested[]
// INITIALISE outdated[]

// LOOP over projects
    // IF untested match
        // ADD to untested[]
    // IF outdated match
        // SET lastSuccessfullRunDaysAgo
        // IF lastSuccessfullRunDaysAgo > 5 && < 15
            // ADD to outdates[5ago]
        // IF lastSuccessfullRunDaysAgo > 15 && < 30
            // ADD to outdates[15ago]
        // IF lastSuccessfullRunDaysAgo > 30 && < 60
            // ADD to outdates[30ago]
        // IF lastSuccessfullRunDaysAgo > 60
            // ADD to outdates[60ago]

export default {
  css: {
    tabContent: {
      styles: {
        maxHeight: '245px',
        overflowY: 'auto',
      },
      classes: ['mx-3', 'my-2'],
    },
  },
  components: { GlTabs, GlTab },
  data() {
    return {
      untested: [
        { path: 'untested/foo/bar-1', id: '1' },
        { path: 'untested/foo/bar-2', id: '2' },
        { path: 'untested/foo/bar-3', id: '3' },
        { path: 'untested/foo/bar-4', id: '4' },
        { path: 'untested/foo/bar-5', id: '5' },
        { path: 'untested/foo/bar-6', id: '6' },
      ],
      outdated: [
        {
          dateInfo: __('5 days ago'),
          projects: [
            { path: 'outdated/5days/foo/bar-1', id: '1' },
            { path: 'outdated/5days/foo/bar-2', id: '2' },
            { path: 'outdated/5days/foo/bar-3', id: '3' },
            { path: 'outdated/5days/foo/bar-4', id: '4' },
            { path: 'outdated/5days/foo/bar-5', id: '5' },
            { path: 'outdated/5days/foo/bar-6', id: '6' },
          ],
        },
        {
          dateInfo: __('15 days ago'),
          projects: [
            { path: 'outdated/15days/foo/bar-1', id: '1' },
            { path: 'outdated/15days/foo/bar-2', id: '2' },
            { path: 'outdated/15days/foo/bar-3', id: '3' },
            { path: 'outdated/15days/foo/bar-4', id: '4' },
            { path: 'outdated/15days/foo/bar-5', id: '5' },
            { path: 'outdated/15days/foo/bar-6', id: '6' },
          ],
        },
      ],
    };
  },
};
</script>
<template>
  <section class="border rounded">
    <header class="px-3 pt-3 mb-0">
      <h4 class="my-0">{{ __('Project scanning') }}</h4>
      <p class="text-secondary mb-0">{{ __('Default branch scanning by project') }}</p>
    </header>
    <div>
      <gl-tabs>
        <gl-tab title="First" title-item-class="ml-3">
          <template #title>
            {{ __('Out of date') }}
          </template>
          <div :class="$options.css.tabContent.classes" :style="$options.css.tabContent.styles">
            <div v-for="dateRange in outdated" :key="dateRange.dateInfo">
              <h5>{{ dateRange.dateInfo }}</h5>
              <ul class="list-unstyled">
                <li v-for="project in dateRange.projects" :key="project.id">{{ project.path }}</li>
              </ul>
            </div>
          </div>
        </gl-tab>
        <gl-tab title="First" title-item-class="ml-3">
          <template #title>
            {{ __('Untested') }}
          </template>
          <div :class="$options.css.tabContent.classes" :style="$options.css.tabContent.styles">
            Second Content
          </div>
        </gl-tab>
      </gl-tabs>
    </div>
  </section>
</template>
