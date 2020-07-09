import { shallowMount } from '@vue/test-utils';
import PagerDutySettingsForm from '~/incidents_settings/components/pagerduty_form.vue';
import { GlAlert } from '@gitlab/ui';

describe('Alert integration settings form', () => {
  let wrapper;
  const resetWebhookUrl = jest.fn();
  const service = { updateSettings: jest.fn().mockResolvedValue(), resetWebhookUrl };

  const findForm = () => wrapper.find({ ref: 'settingsForm' });
  const findWebhookResetBtn = () => wrapper.find('[data-testid="webhook-reset-btn"]');
  const findAlert = () => wrapper.find(GlAlert);

  beforeEach(() => {
    wrapper = shallowMount(PagerDutySettingsForm, {
      provide: {
        service,
        pagerDutySettings: {
          active: true,
          webhookUrl: 'pagerduty.webhook.com',
          webhookUpdateEndpoint: 'webhook/update',
        },
      },
    });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  it('should match the default snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('should call service `updateSettings` on form submit', () => {
    findForm().trigger('submit');
    expect(service.updateSettings).toHaveBeenCalledWith(
      expect.objectContaining({ settingsKey: 'pager_duty_setting_attributes' }),
    );
  });

  describe('Webhook reset', () => {
    it('should show success message and reset webhook url', () => {
      const newWebhookUrl = 'new.webhook.url';
      resetWebhookUrl.mockResolvedValueOnce(newWebhookUrl);
      findWebhookResetBtn().vm.$emit('click');
      return wrapper.vm.$nextTick().then(() => {
        expect(service.resetWebhookUrl).toHaveBeenCalled();
        expect(findAlert().attributes('variant')).toBe('success');
      });
    });

    it('should show error message and NOT reset webhook url', () => {
      resetWebhookUrl.mockRejectedValueOnce();
      findWebhookResetBtn().vm.$emit('click');
      return wrapper.vm.$nextTick().then(() => {
        expect(findAlert().attributes('variant')).toBe('danger');
      });
    });
  });
});
