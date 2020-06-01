const createCleanHTMLSnapshotSerializer = () => {
  return {
    test(value) {
      return value instanceof HTMLElement && !value.$_hit;
    },
    print(element, serialize) {
      element.$_hit = true;
      element.querySelectorAll('[style]').forEach(el => {
        el.$_hit = true;
        if (el.style.display === 'none') {
          el.textContent = '(jest: contents hidden)';
        }
      });

      const result = serialize(element);

      return result.replace(/^\s*<!---->\s*$/gm, '').replace(/\n\s*\n/gm, '\n');
    },
  };
};

export default createCleanHTMLSnapshotSerializer;
