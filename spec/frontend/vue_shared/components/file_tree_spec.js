import { shallowMount } from '@vue/test-utils';
import FileTree from '~/vue_shared/components/file_tree.vue';

const mockFileRowComponent = {
  name: 'MockFileRowComponent',
  template: '<div>hello</div>',
};

describe('File Tree component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(FileTree, {
      propsData: { ...props },
    });
  };

  const findFileRow = () => wrapper.find(mockFileRowComponent);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('file row component', () => {
    const attributes = {
      level: 4,
      file: {},
    };
    beforeEach(() => {
      createComponent({
        fileRowComponent: mockFileRowComponent,
        ...attributes,
      });
    });

    it('renders file row component', () => {
      expect(findFileRow().exists()).toEqual(true);
    });

    it('contains the required attribute keys', () => {
      const attributesKey = Object.keys(attributes);
      const fileRowAttributesKey = Object.keys(findFileRow().attributes());

      // Checking key instead b/c value in attributes are always strings
      // <mockfilerowcomponent-stub level="4" file="[object Object]"></mockfilerowcomponent-stub>
      expect(findFileRow().exists()).toEqual(true);
      expect(fileRowAttributesKey).toEqual(attributesKey);
    });
  });

  it('shows file tree if file is open or is header', () => {
    createComponent({
      fileRowComponent: mockFileRowComponent,
      level: 4,
      file: {
        opened: true,
        tree: [{}, {}],
      },
    });
    expect(wrapper.findAll(FileTree).length).toEqual(3);
  });

  describe('file tree', () => {
    it.each`
      key           | value    | desc                             | fileTreeLength
      ${'isHeader'} | ${true}  | ${'is shown if file is header'}  | ${3}
      ${'opened'}   | ${true}  | ${'is shown if file is open'}    | ${3}
      ${'isHeader'} | ${false} | ${'is hidden if file is header'} | ${1}
      ${'opened'}   | ${false} | ${'is hidden if file is open'}   | ${1}
    `('$desc', ({ key, value, fileTreeLength }) => {
      createComponent({
        fileRowComponent: mockFileRowComponent,
        level: 4,
        file: {
          [key]: value,
          tree: [{}, {}],
        },
      });
      expect(wrapper.findAll(FileTree).length).toEqual(fileTreeLength);
    });
  });
});
