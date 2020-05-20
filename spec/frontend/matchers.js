export default {
  toHaveSpriteIcon: (element, iconName) => {
    if (!iconName) {
      throw new Error('toHaveSpriteIcon is missing iconName argument!');
    }

    if (!(element instanceof HTMLElement)) {
      throw new Error(`${element} is not a DOM element!`);
    }

    const iconReferences = [].slice.apply(element.querySelectorAll('svg use'));
    const matchingIcon = iconReferences.find(reference =>
      reference.getAttribute('xlink:href').endsWith(`#${iconName}`),
    );

    const pass = Boolean(matchingIcon);

    let message;
    if (pass) {
      message = `${element.outerHTML} contains the sprite icon "${iconName}"!`;
    } else {
      message = `${element.outerHTML} does not contain the sprite icon "${iconName}"!`;

      const existingIcons = iconReferences.map(reference => {
        const iconUrl = reference.getAttribute('xlink:href');
        return `"${iconUrl.replace(/^.+#/, '')}"`;
      });
      if (existingIcons.length > 0) {
        message += ` (only found ${existingIcons.join(',')})`;
      }
    }

    return {
      pass,
      message: () => message,
    };
  },
  toMatchInterpolatedText(received, match) {
    const clearReceived = received
      .replace(/\s\s+/gm, ' ')
      .replace(/\s\./gm, '.')
      .trim();

    const clearMatch = match.replace(/%{\w+}/gm, '').trim();
    const pass = clearReceived === clearMatch;
    const message = pass
      ? () => `
          \n\n
          Expected: not ${this.utils.printExpected(clearReceived)}
          Received: ${this.utils.printReceived(clearMatch)}
          `
      : () => `
        \n\n
        Expected: ${this.utils.printExpected(clearReceived)}
        Received: ${this.utils.printReceived(clearMatch)}
        `;

    return { actual: received, message, pass };
  },
};
