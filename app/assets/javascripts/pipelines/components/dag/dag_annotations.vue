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
    notesArray() {
      return Object.values(this.annotations)
    }
  },
}

</script>
<template>
  <div>
    <div v-for="note in notesArray" :key="note.uuid">
      {{ `${note.source.name} ↠ ${note.target.name} (${note.source.color} ↠ ${note.target.color})` }}
    </div>
  </div>
</template>
