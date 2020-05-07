<script>
import { GlPagination, GlTooltipDirective, GlDeprecatedButton, GlIcon } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

import {
  ASYNC_DELETE_IMAGE_ERROR_MESSAGE,
  LIST_DELETE_BUTTON_DISABLED,
  REMOVE_REPOSITORY_LABEL,
  ROW_SCHEDULED_FOR_DELETION,
} from '../constants';

export default {
  name: 'ImageList',
  components: {
    GlPagination,
    ClipboardButton,
    GlDeprecatedButton,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    images: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
      required: true,
    },
  },
  i18n: {
    LIST_DELETE_BUTTON_DISABLED,
    REMOVE_REPOSITORY_LABEL,
    ROW_SCHEDULED_FOR_DELETION,
    ASYNC_DELETE_IMAGE_ERROR_MESSAGE,
  },
  computed: {
    currentPage: {
      get() {
        return this.pagination.page;
      },
      set(page) {
        this.$emit('pageChange', page);
      },
    },
  },
  methods: {
    encodeListItem(item) {
      const params = JSON.stringify({ name: item.path, tags_path: item.tags_path, id: item.id });
      return window.btoa(params);
    },
  },
};
</script>

<template>
  <div class="d-flex flex-column">
    <div
      v-for="(listItem, index) in images"
      :key="index"
      ref="rowItem"
      v-gl-tooltip="{
        placement: 'left',
        disabled: !listItem.deleting,
        title: $options.i18n.ROW_SCHEDULED_FOR_DELETION,
      }"
    >
      <div
        class="d-flex justify-content-between align-items-center py-2 px-1 border-bottom"
        :class="{ 'border-top': index === 0, 'disabled-content': listItem.deleting }"
      >
        <div class="d-felx align-items-center">
          <router-link
            ref="detailsLink"
            :to="{ name: 'details', params: { id: encodeListItem(listItem) } }"
          >
            {{ listItem.path }}
          </router-link>
          <clipboard-button
            v-if="listItem.location"
            ref="clipboardButton"
            :disabled="listItem.deleting"
            :text="listItem.location"
            :title="listItem.location"
            css-class="btn-default btn-transparent btn-clipboard"
          />
          <gl-icon
            v-if="listItem.failedDelete"
            v-gl-tooltip
            :title="$options.i18n.ASYNC_DELETE_IMAGE_ERROR_MESSAGE"
            name="warning"
            class="text-warning align-middle"
          />
        </div>
        <div
          v-gl-tooltip="{ disabled: listItem.destroy_path }"
          class="d-none d-sm-block"
          :title="$options.i18n.LIST_DELETE_BUTTON_DISABLED"
        >
          <gl-deprecated-button
            ref="deleteImageButton"
            v-gl-tooltip
            :disabled="!listItem.destroy_path || listItem.deleting"
            :title="$options.i18n.REMOVE_REPOSITORY_LABEL"
            :aria-label="$options.i18n.REMOVE_REPOSITORY_LABEL"
            class="btn-inverted"
            variant="danger"
            @click="$emit('delete', listItem)"
          >
            <gl-icon name="remove" />
          </gl-deprecated-button>
        </div>
      </div>
    </div>
    <gl-pagination
      v-model="currentPage"
      :per-page="pagination.perPage"
      :total-items="pagination.total"
      align="center"
      class="w-100 mt-2"
    />
  </div>
</template>
