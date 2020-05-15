import { shallowMount } from '@vue/test-utils';
import BlobContentError from '~/blob/components/blob_content_error.vue';
import { GlSprintf } from '@gitlab/ui';

import { BLOB_RENDER_ERRORS } from '~/blob/components/constants';

describe('Blob Content Error component', () => {
  let wrapper;

  function createComponent(props = {}) {
    wrapper = shallowMount(BlobContentError, {
      propsData: {
        ...props,
      },
      stubs: {
        GlSprintf,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it.each`
    error                                   | text
    ${BLOB_RENDER_ERRORS.REASONS.COLLAPSED} | ${'it is larger than 1.00 MiB'}
    ${BLOB_RENDER_ERRORS.REASONS.TOO_LARGE} | ${'it is larger than 100.00 MiB'}
    ${BLOB_RENDER_ERRORS.REASONS.EXTERNAL}  | ${'it is stored externally'}
  `('renders correct message for $error.id', ({ error, text }) => {
    createComponent({
      viewerError: error.id,
    });
    expect(wrapper.text()).toContain(text);
  });
});
