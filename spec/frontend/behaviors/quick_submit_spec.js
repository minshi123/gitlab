import $ from 'jquery';
import '~/behaviors/quick_submit';
import Vue from 'vue';

describe('Quick Submit behavior', () => {
  const keydownEvent = (options = { keyCode: 13, metaKey: true }) => $.Event('keydown', options);
  const obj = {};

  preloadFixtures('snippets/show.html');

  beforeEach(() => {
    loadFixtures('snippets/show.html');
    const submitSpy = jest.fn().mockName('submit');
    $('form').submit(e => {
      // Prevent a form submit from moving us off the testing page
      e.preventDefault();
      submitSpy();
    });
    obj.spies = {
      submit: submitSpy,
    };

    obj.textarea = $('.js-quick-submit textarea').first();
  });

  afterEach(() => {
    // Undo what we did to the shared <body>
    $('body').removeAttr('data-page');
  });

  it('does not respond to other keyCodes', () => {
    obj.textarea.trigger(
      keydownEvent({
        keyCode: 32,
      }),
    );

    expect(obj.spies.submit).not.toHaveBeenCalled();
  });

  it('does not respond to Enter alone', () => {
    obj.textarea.trigger(
      keydownEvent({
        ctrlKey: false,
        metaKey: false,
      }),
    );

    expect(obj.spies.submit).not.toHaveBeenCalled();
  });

  it('does not respond to repeated events', () => {
    obj.textarea.trigger(
      keydownEvent({
        repeat: true,
      }),
    );

    expect(obj.spies.submit).not.toHaveBeenCalled();
  });

  it('disables input of type submit', () => {
    const submitButton = $('.js-quick-submit input[type=submit]');
    obj.textarea.trigger(keydownEvent());

    expect(submitButton).toBeDisabled();
  });

  it('disables button of type submit', () => {
    const submitButton = $('.js-quick-submit input[type=submit]');
    obj.textarea.trigger(keydownEvent());

    expect(submitButton).toBeDisabled();
  });

  it('only clicks one submit', done => {
    const existingSubmit = $('.js-quick-submit input[type=submit]');
    // Add an extra submit button
    const newSubmit = $('<button type="submit">Submit it</button>');
    newSubmit.insertAfter(obj.textarea);

    const oldClick = jest.fn().mockName('click');
    const newClick = jest.fn().mockName('click');

    existingSubmit.on('click', oldClick);
    newSubmit.on('click', newClick);

    obj.textarea.trigger(keydownEvent());

    Vue.nextTick()
      .then(() => {
        expect(oldClick).not.toHaveBeenCalled();
        expect(newClick).toHaveBeenCalled();
      })
      .then(done)
      .catch(done.fail);
  });
  // We cannot stub `navigator.userAgent` for CI's `rake karma` task, so we'll
  // only run the tests that apply to the current platform
  if (navigator.userAgent.match(/Macintosh/)) {
    describe('In Macintosh', () => {
      it('responds to Meta+Enter', () => {
        obj.textarea.trigger(keydownEvent());

        expect(obj.spies.submit).toHaveBeenCalled();
      });

      it('excludes other modifier keys', () => {
        obj.textarea.trigger(
          keydownEvent({
            altKey: true,
          }),
        );
        obj.textarea.trigger(
          keydownEvent({
            ctrlKey: true,
          }),
        );
        obj.textarea.trigger(
          keydownEvent({
            shiftKey: true,
          }),
        );

        expect(obj.spies.submit).not.toHaveBeenCalled();
      });
    });
  } else {
    it('responds to Ctrl+Enter', () => {
      obj.textarea.trigger(keydownEvent());

      expect(obj.spies.submit).toHaveBeenCalled();
    });

    it('excludes other modifier keys', () => {
      obj.textarea.trigger(
        keydownEvent({
          altKey: true,
        }),
      );
      obj.textarea.trigger(
        keydownEvent({
          metaKey: true,
        }),
      );
      obj.textarea.trigger(
        keydownEvent({
          shiftKey: true,
        }),
      );

      expect(obj.spies.submit).not.toHaveBeenCalled();
    });
  }
});
