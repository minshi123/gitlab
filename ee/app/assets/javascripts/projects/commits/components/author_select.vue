<script>
import { __ } from '~/locale';
import {
  GlNewDropdown,
  GlNewDropdownHeader,
  GlNewDropdownItem,
  GlSearchBoxByType,
  GlNewDropdownDivider,
} from '@gitlab/ui';

export default {
  name: 'AuthorSelect',
  components: {
    GlNewDropdown,
    GlNewDropdownHeader,
    GlNewDropdownItem,
    GlSearchBoxByType,
    GlNewDropdownDivider,
  },
  data() {
    return {
      username: 'hi',
      searchTerm: '',
      avatars: ['one', 'two', 'three'],
    };
  },
  computed: {
    filteredAvatars() {
      return this.avatars.filter(item =>
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
      <gl-new-dropdown-item
        v-for="avatar in filteredAvatars"
        :key="avatar"
        :active="avatar === username"
      >
        {{ avatar }}
      </gl-new-dropdown-item>
    </gl-new-dropdown>
  </div>
</template>
