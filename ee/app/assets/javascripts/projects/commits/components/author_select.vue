<script>
import { mapState } from 'vuex';
import {
  GlNewDropdown,
  GlNewDropdownHeader,
  GlNewDropdownItem,
  GlSearchBoxByType,
  GlNewDropdownDivider,
} from '@gitlab/ui';
import { redirectTo, getParameterValues } from '~/lib/utils/url_utility';

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
      searchTerm: '',
      avatars: ['rob', 'lee', 'three'],
    };
  },
  computed: {
    ...mapState(['commitsPath']),
    filteredAvatars() {
      return this.avatars.filter(item =>
        item.toLowerCase().includes(this.searchTerm.toLowerCase()),
      );
    },
    currentAuthor() {
      return getParameterValues('author')[0];
    },
  },
  methods: {
    selectAuthor(user) {
      const commitListElement = document.getElementById('commits-list');
      commitListElement.style.opacity = 0.5;
      commitListElement.style.transition = 'opacity 200ms'; // To match 'fast' in jQuery

      if (user === null) {
        return redirectTo(this.commitsPath);
      }

      return redirectTo(`${this.commitsPath}?author=${user}`);
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
      <gl-new-dropdown-item :is-checked="!currentAuthor" @click.prevent="selectAuthor(null)">
        {{ __('Any Author') }}
      </gl-new-dropdown-item>
      <gl-new-dropdown-divider />
      <!-- avatar-url="https://secure.gravatar.com/avatar/78b060780d36f51a6763ac9831a4f022?s=180&d=identicon"
        secondary-text="@sytses" -->
      <gl-new-dropdown-item
        v-for="avatar in filteredAvatars"
        :key="avatar"
        :is-checked="avatar === currentAuthor"
        @click.prevent="selectAuthor(avatar)"
      >
        {{ avatar }}
      </gl-new-dropdown-item>
    </gl-new-dropdown>
  </div>
</template>
