import Tracking from '~/tracking';

document.addEventListener('SnowplowInitialized', () => {
  const flashText = document.querySelector('.flash-text');

  if (flashText) {
    const errorMessage = flashText.textContent.trim();

    if (errorMessage) {
      Tracking.event('trials:create', 'create_trial_error', {
        label: 'flash-text',
        property: 'message',
        value: errorMessage,
      });
    }
  }
});
