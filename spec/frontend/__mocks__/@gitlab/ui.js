export * from '@gitlab/ui';

/**
 * The @gitlab/ui tooltips and popovers require awkward and distracting set up in tests
 * for components that use them (e.g., `attachToDocument: true` and `sync: true` passed
 * to the `mount` helper from `vue-test-utils`).
 *
 * These mocks decouple those tests from the implementation, removing the need to set
 * them up specially.
 */
export const GlTooltipDirective = {
  bind() {},
};

export const GlTooltip = {
  render(h) {
    return h('div', this.$attrs, this.$slots.default);
  },
};

export const GlPopover = {
  render(h) {
    return h('div', this.$attrs);
  },
};
