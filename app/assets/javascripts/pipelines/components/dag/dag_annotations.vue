<script>

export default {
  name: 'DagAnnotations',
  props: {
    annotations: {
      type: Object,
      required: true,
    },
  },
}

</script>
<template>
  <div class="gl-display-flex gl-flex-wrap">
    <div v-for="note in annotations" :key="note.uuid" class="gl-ml-4 gl-display-flex gl-align-items-center">
      <div class="gl-text-white gl-px-2 gl-font-base pointy-polygon gl-align-items-center" :style="{ backgroundColor: note.source.color}">
        <p class="gl-m-0">{{ note.source.name }}</p>
      </div>
      <div class="gl-text-white gl-px-2 gl-font-base indented-polygon gl-align-items-center" :style="{ backgroundColor: note.target.color, marginLeft: '-20px'  }">
        <p class="gl-m-0">{{ note.target.name }}</p>
      </div>
    </div>
  </div>
</template>
