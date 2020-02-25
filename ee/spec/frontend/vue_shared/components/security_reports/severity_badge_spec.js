import { shallowMount } from '@vue/test-utils';
import SeverityBadge from 'ee/vue_shared/security_reports/components/severity_badge.vue';

describe('Severity Badge', () => {
  let wrapper;

  const factory = (propsData = {}) =>
    shallowMount(SeverityBadge, {
      propsData: { ...propsData },
    });

  const SEVERITY_MAP = {
    critical: 'text-danger-800',
    high: 'text-danger-600',
    medium: 'text-warning-400',
    low: 'text-warning-300',
    info: 'text-primary-400',
    unknown: 'text-secondary-400',
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Render', () => {
    Object.keys(SEVERITY_MAP).forEach(severity => {
      const className = SEVERITY_MAP[severity];

      it(`renders the component with ${severity} badge`, () => {
        wrapper = factory({ severity });

        expect(wrapper.findAll(`span.${className}`).exists()).toBe(true);
      });
    });
  });

  describe('computed props', () => {
    describe('hasSeverityBadge', () => {
      describe('when security is defined', () => {
        it('returns true', () => {
          wrapper = factory({ severity: 'critical' });
          expect(wrapper.vm.hasSeverityBadge).toBe(true);
        });
      });
      describe('when security is a space', () => {
        it('returns false', () => {
          wrapper = factory({ severity: ' ' });
          expect(wrapper.vm.hasSeverityBadge).toBe(false);
        });
      });
      describe('when security is empty', () => {
        it('returns false', () => {
          wrapper = factory({ severity: '' });
          expect(wrapper.vm.hasSeverityBadge).toBe(false);
        });
      });
    });
  });

  describe('severityKey', () => {
    describe('when security is critical', () => {
      it('returns critical', () => {
        wrapper = factory({ severity: 'Critical' });
        expect(wrapper.vm.severityKey).toBe('critical');
      });
    });
  });

  describe('className', () => {
    describe('when security is critical', () => {
      it(`returns ${SEVERITY_MAP.critical}`, () => {
        wrapper = factory({ severity: 'Critical' });
        expect(wrapper.vm.className).toBe(SEVERITY_MAP.critical);
      });
    });
  });

  describe('iconName', () => {
    describe('when security is critical', () => {
      it('returns severity-critical', () => {
        wrapper = factory({ severity: 'critical' });
        expect(wrapper.vm.iconName).toBe('severity-critical');
      });
    });
  });

  describe('severityTitle', () => {
    describe('when security is critical', () => {
      it('returns Critical', () => {
        wrapper = factory({ severity: 'critical' });
        expect(wrapper.vm.severityTitle).toBe('Critical');
      });
    });
  });
});
