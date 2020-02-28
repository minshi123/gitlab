import { shallowMount } from '@vue/test-utils';
import SeverityBadge from 'ee/vue_shared/security_reports/components/severity_badge.vue';

describe('Severity Badge', () => {
  let wrapper;

  const severities = ['Critical', 'High'];
  const { CLASS_NAME_MAP } = SeverityBadge.components;

  const factory = (propsData = {}) =>
    shallowMount(SeverityBadge, {
      propsData: { ...propsData },
    });

  describe('Render', () => {
    describe('class names', () => {
      Object.keys(CLASS_NAME_MAP).forEach(severity => {
        const className = CLASS_NAME_MAP[severity];

        it(`renders the component with ${severity} badge`, () => {
          wrapper = factory({ severity });

          expect(wrapper.find(`span.${className}`).exists()).toBe(true);
        });
      });

      describe('labels', () => {
        it(`renders the component label for Critical`, () => {
          wrapper = factory({ severity: 'Critical' });

          expect(wrapper.text()).toContain('Critical');
        });

        it(`renders the component label for Medium`, () => {
          wrapper = factory({ severity: 'Medium' });

          expect(wrapper.text()).toContain('Medium');
        });
      });
    });
  });
});
