import { shallowMount } from '@vue/test-utils';
import DiffFileRow from '~/diffs/components/diff_file_row.vue';
import FileRow from '~/vue_shared/components/file_row.vue';
import FileRowStats from '~/diffs/components/file_row_stats.vue';

describe('Diff File Row component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(DiffFileRow, {
      propsData: { ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders file row component', () => {
    createComponent({
      level: 4,
      file: {},
    });
    expect(wrapper.find(FileRow).exists()).toEqual(true);
  });

  describe('FileRowStats components', () => {
    it.each`
      type       | value    | desc
      ${'blob'}  | ${true}  | ${'is shown if file type is blob'}
      ${'hello'} | ${false} | ${'is hidden if file is not blob'}
    `('$desc', ({ type, value }) => {
      createComponent({
        level: 4,
        file: {
          type,
        },
      });
      expect(wrapper.find(FileRowStats).exists()).toEqual(value);
    });
  });
});
