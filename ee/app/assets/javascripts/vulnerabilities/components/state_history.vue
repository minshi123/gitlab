<script>
import axios from '~/lib/utils/axios_utils';
import Poll from '~/lib/utils/poll';
import Icon from '~/vue_shared/components/icon.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: { Icon, TimeAgoTooltip },

  data: () => ({
    notes: [],
  }),

  mounted() {
    let lastFetchedAt;

    const headers = {
      // Use a getter here so that every time this property is fetched, it will get the most recent value.
      get 'X-Last-Fetched-At'() {
        return lastFetchedAt;
      },
    };

    const poll = new Poll({
      resource: { getNewNotes: () => axios.get(`${window.location.href}/notes`, { headers }) },
      method: 'getNewNotes',
      successCallback: ({ data }) => {
        lastFetchedAt = data.last_fetched_at;
        this.notes = this.notes.concat(data.notes);
      },
    });

    poll.makeRequest();
  },
};
</script>

<template>
  <ul class="notes">
    <li
      v-for="note in notes"
      :key="note.discussion_id"
      class="card border-bottom px-3 py-4 system-note note-header-info"
    >
      <div class="timeline-icon mr-2">
        <icon :name="note.system_note_icon_name" />
      </div>
      <a :href="note.author.path" class="js-user-link" :data-user-id="note.author.id">
        <strong class="note-header-author-name">{{ note.author.name }}</strong>
        @{{ note.author.username }}
      </a>
      <span class="d-inline note-headline-light">
        {{ note.note }}
        <time-ago-tooltip :time="note.updated_at" />
      </span>
    </li>
  </ul>
</template>
