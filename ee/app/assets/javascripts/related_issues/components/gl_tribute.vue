<script>
import Tribute from 'tributejs';

export default {
  name: 'GlTribute',
  props: {
    options: {
      type: Object,
      required: true,
    },
  },
  watch: {
    options: {
      immediate: false,
      deep: true,
      handler() {
        if (this.tribute) {
          setTimeout(() => {
            let $el = this.$slots.default[0].elm;
            this.tribute.detach($el);
            console.log('handler detaching')

            setTimeout(() => {
              $el = this.$slots.default[0].elm;
              this.tribute = new Tribute(this.options);
              this.tribute.attach($el);
              $el.tributeInstance = this.tribute;

              console.log('handler reattaching')
            }, 0);
          }, 0);
        }
      },
    },
  },
  mounted() {
    if (typeof Tribute === 'undefined') {
      throw new Error('[vue-tribute] cannot locate tributejs!');
    }

    const $el = this.$slots.default[0].elm;
    this.tribute = new Tribute(this.options);
    this.tribute.attach($el);
    $el.tributeInstance = this.tribute;

    console.log('mounted', this.tribute)
  },
  beforeDestroy() {
    const $el = this.$slots.default[0].elm;

    if (this.tribute) {
      this.tribute.detach($el);
    }

    console.log('beforedestroy', this.tribute)
  },
  render(h) {
    return h(
      'div',
      {
        staticClass: 'v-tribute',
      },
      this.$slots.default,
    );
  },
};

// if (typeof window !== 'undefined' && window.Vue) {
//   window.Vue.component(VueTribute.name, VueTribute)
// }
// export default VueTribute
</script>

<style>
  .v-tribute {
    background-color: red;
  }
</style>
