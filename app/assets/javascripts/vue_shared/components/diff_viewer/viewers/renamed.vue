<script>
  import { mapActions } from 'vuex';

  export default {
    props: {
      diffFile: {
        type: Object,
        required: true,
      },
    },
    methods: {
      ...mapActions('diffs', [
        'switchToFullDiffFromRenamedFile',
      ]),
    },
  };
</script>

<template>
  <div class="nothing-here-block">
    {{ __('File moved') }}
    <a
      v-if="diffFile.alternate_viewer.name === 'text'"
      href="#"
      @click.prevent="switchToFullDiffFromRenamedFile( { diffFile } )"
    >
      {{ __('(Show file)') }}
    </a>
  </div>
</template>
