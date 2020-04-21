<script>
import 'codemirror/lib/codemirror.css';
import '@toast-ui/editor/dist/toastui-editor.css';

export default {
  components: {
    ToastEditor: () =>
      import(/* webpackChunkName: 'toast_editor' */ '@toast-ui/vue-editor').then(
        toast => toast.Editor,
      ),
  },
  props: {
    value: {
      type: String,
      required: true,
    },
  },
  computed: {
    markdown() {
      return this.$refs.editor.invoke('getMarkdown');
    },
  },
  methods: {
    onContentChanged() {
      this.$emit('input', this.markdown);
    },
  },
};
</script>
<template>
  <toast-editor ref="editor" :initial-value="value" @change="onContentChanged" />
</template>
