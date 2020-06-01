import useTestHelper from './ide_helper';

describe('WebIDE', () => {
  const {
    setup,
    destroy,
    mount,
    expectSnapshot,
    expectDiffSnapshot,
    withProjectData,
    waitForRequests,
  } = useTestHelper();

  beforeEach(setup);
  afterEach(destroy);

  it('loads', async () => {
    withProjectData();
    mount();

    expectSnapshot();

    await waitForRequests();

    expectDiffSnapshot();
  });
});
