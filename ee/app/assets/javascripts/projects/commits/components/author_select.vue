<script>
import $ from 'jquery';
import 'select2/select2';
import _ from 'underscore';
import Api from 'ee/api';
import { __ } from '~/locale';
import Select2Select from '~/vue_shared/components/select2_select.vue';
import {
  GlNewDropdown,
  GlNewDropdownHeader,
  GlNewDropdownItem,
  GlSearchBoxByType,
  GlNewDropdownDivider,
  GlAvatar,
} from '@gitlab/ui';

const SORT_OPTIONS = [
  { key: 'DESC', text: __('Newest first'), cls: 'js-newest-first' },
  { key: 'ASC', text: __('Oldest first'), cls: 'js-oldest-first' },
];

export default {
  SORT_OPTIONS,
  name: 'AuthorSelect',
  components: {
    Select2Select,
    GlNewDropdown,
    GlNewDropdownHeader,
    GlNewDropdownItem,
    GlSearchBoxByType,
    GlNewDropdownDivider,
    GlAvatar,
  },
  data() {
    return {
      username: 'hi',
      searchTerm: '',
      allList: ['one', 'two', 'three'],
      avatars: [{}],
    };
  },
  computed: {
    select2Options() {
      return {
        data: this.authorOptions,
        containerCssClass: '',
      };
    },
    authorOptions() {
      return [{ id: 1, text: __('one') }, { id: 2, text: __('two') }, { id: 3, text: __('three') }];
    },
    filteredList() {
      return this.allList.filter(item =>
        item.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
  },
};
</script>

<template>
  <div class="">
    <gl-new-dropdown text="Author">
      <gl-new-dropdown-header>
        {{ __('Filter by author') }}
      </gl-new-dropdown-header>
      <gl-new-dropdown-divider />
      <gl-search-box-by-type
        v-model.trim="searchTerm"
        class="m-2"
        :placeholder="__(`Search authors`)"
        autofocus
      />
      <gl-new-dropdown-item :is-checked="true">
        {{ __('Any Author') }}
      </gl-new-dropdown-item>
      <gl-new-dropdown-divider />
      <!-- avatar-url="https://secure.gravatar.com/avatar/78b060780d36f51a6763ac9831a4f022?s=180&d=identicon"
        secondary-text="@sytses" -->
      <gl-new-dropdown-item v-for="item in filteredList" :key="item" :active="item === username">
        {{ item }}
      </gl-new-dropdown-item>
    </gl-new-dropdown>

    <!-- <select2-select v-model="username" :options="select2Options" /> -->
    <!-- <div class="dropdown">
      <button class="btn btn-sm js-dropdown-text" data-toggle="dropdown" aria-expanded="false">
        hello there
        <gl-icon name="chevron-down" />
      </button>
      <div ref="dropdownMenu" class="dropdown-menu dropdown-menu-selectable dropdown-menu-right">
        <div class="dropdown-content">
          <ul>
            <li v-for="{ text, key, cls } in $options.SORT_OPTIONS" :key="key">
              <button type="button">
                {{ text }}
              </button>
            </li>
          </ul>
        </div>
      </div>
    </div> -->
  </div>
</template>
