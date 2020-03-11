import { shallowMount } from '@vue/test-utils';
import { GlBadge, GlPopover } from '@gitlab/ui';
import RemediatedBadge from 'ee/vulnerabilities/components/remediated_badge.vue';

describe('Remediated badge component', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(RemediatedBadge);
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  afterEach(() => wrapper.destroy());

  it('should link the badge and the popover', () => {
    const badge = wrapper.find(GlBadge);
    const popover = wrapper.find(GlPopover);

    expect(badge.attributes().id).toEqual(popover.attributes().target);
  });

  it('should pass down the data to the popover', () => {
    const popoverAttributes = wrapper.find(GlPopover).attributes();
    const { popoverTitle, popoverContent } = wrapper.vm.$options.strings;

    expect(popoverAttributes.title).toEqual(popoverTitle);
    expect(popoverAttributes.content).toEqual(popoverContent);
  });
});
