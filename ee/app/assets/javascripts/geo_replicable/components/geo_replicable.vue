<script>
import { mapState, mapActions } from 'vuex';
import { GlPagination, GlIcon } from '@gitlab/ui';
import GeoReplicableItem from './geo_replicable_item.vue';

export default {
  name: 'GeoReplicable',
  components: {
    GlPagination,
    GlIcon,
    GeoReplicableItem,
  },
  computed: {
    ...mapState(['replicableItems', 'paginationData', 'useGraphQl']),
    page: {
      get() {
        return this.paginationData.page;
      },
      set(newVal) {
        this.setPage(newVal);
        this.fetchReplicableItems();
      },
    },
    showRestfulPagination() {
      return !this.useGraphQl && this.paginationData.total > 0;
    },
    showGraphQlPagination() {
      return (
        this.useGraphQl &&
        this.replicableItems.length > 0 &&
        (this.paginationData.hasNextPage || this.paginationData.hasPreviousPage)
      );
    },
  },
  methods: {
    ...mapActions(['setPage', 'fetchReplicableItems']),
    buildName(item) {
      return item.name ? item.name : item.id;
    },
  },
};
</script>

<template>
  <section>
    <geo-replicable-item
      v-for="item in replicableItems"
      :key="item.id"
      :name="buildName(item)"
      :project-id="item.projectId"
      :sync-status="item.state.toLowerCase()"
      :last-synced="item.lastSyncedAt"
      :last-verified="item.lastVerifiedAt"
      :last-checked="item.lastCheckedAt"
    />
    <gl-pagination
      v-if="showRestfulPagination"
      v-model="page"
      :per-page="paginationData.perPage"
      :total-items="paginationData.total"
      align="center"
    />
    <div v-if="showGraphQlPagination" class="text-center">
      <ul class="pagination gl-pagination text-nowrap justify-content-center">
        <li
          class="page-item"
          :class="{
            disabled: !paginationData.hasPreviousPage,
            'gl-cursor-pointer': paginationData.hasPreviousPage,
          }"
          @click="paginationData.hasPreviousPage && fetchReplicableItems('prev')"
        >
          <span class="page-link prev-page-item"
            ><gl-icon name="chevron-left" /> {{ __('Prev') }}</span
          >
        </li>
        <li
          class="page-item"
          :class="{
            disabled: !paginationData.hasNextPage,
            'gl-cursor-pointer': paginationData.hasNextPage,
          }"
          @click="paginationData.hasNextPage && fetchReplicableItems('next')"
        >
          <span class="page-link next-page-item"
            >{{ __('Next') }} <gl-icon name="chevron-right"
          /></span>
        </li>
      </ul>
    </div>
  </section>
</template>
