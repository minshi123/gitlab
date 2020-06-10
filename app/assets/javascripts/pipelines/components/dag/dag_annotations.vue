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
  <div>
    <div v-for="note in annotations" :key="note.uuid">
      {{ `${note.source.name} ↠ ${note.target.name} (${note.source.color} ↠ ${note.target.color})` }}
    </div>
  </div>
</template>
