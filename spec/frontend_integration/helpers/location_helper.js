const useLocationHelper = () => {
  let origLocation;

  return {
    setup({ pathname = '', search = '', hash = '' }) {
      if (!origLocation) {
        origLocation = window.location;
      }

      Object.defineProperty(window, 'location', {
        get() {
          return {
            pathname,
            search,
            hash,
          };
        },
      });
    },

    destroy() {
      Object.defineProperty(window, 'location', {
        get() {
          return origLocation;
        },
      });
    },
  };
};

export default useLocationHelper;
