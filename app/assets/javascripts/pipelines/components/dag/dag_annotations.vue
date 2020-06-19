<script>

export default {
  name: 'DagAnnotations',
  props: {
    annotations: {
      type: Object,
      required: true,
    },
  },
  computed: {
    wrapperClasses() {
      return [
        'gl-display-flex',
        'gl-flex-direction-column',
        'gl-fixed',
        'gl-right-1',
        'gl-w-max-content',
        'gl-pr-5',
        'gl-rounded-base',
        Object.keys(this.annotations).length > 0 ? 'gl-bg-white' : '',
      ].join(' ')
    }
  }
}

</script>
<template>
  <div :class="wrapperClasses">
    <div v-for="note in annotations" :key="note.uid" class="gl-ml-4 gl-display-flex gl-align-items-center">
      <div
        class="gl-w-6 gl-h-5"
        :style="{ background: `linear-gradient(0.25turn, ${note.source.color} 40%, ${note.target.color} 60%)`}"
      />
      <div class="gl-px-2 gl-font-base gl-align-items-center">
        {{ note.source.name }} → {{ note.target.name }}
      </div>
    </div>
  </div>
</template>
