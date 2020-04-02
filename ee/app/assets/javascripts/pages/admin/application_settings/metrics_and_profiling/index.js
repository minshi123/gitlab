import UsagePingPayload from '~/pages/admin/application_settings/usage_ping_payload';

document.addEventListener('DOMContentLoaded', () => {
  new UsagePingPayload(
    document.querySelector('.js-seat-link-payload-trigger'),
    document.querySelector('.js-seat-link-payload'),
  ).init();
});
