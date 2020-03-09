import SnippetDescriptionEdit from '~/snippets/components/snippet_description_edit.vue';
import { shallowMount } from '@vue/test-utils';

describe('Snippet Description Edit component', () => {
  let wrapper;
  let description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
  const markdownPreviewPath = 'foo/';
  const markdownDocsPath = 'help/';

  function createComponent() {
    wrapper = shallowMount(SnippetDescriptionEdit, {
      propsData: {
        description,
        markdownPreviewPath,
        markdownDocsPath,
      },
    });
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('rendering', () => {
    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders the field expnanded when description exists', () => {
      expect(wrapper.find('.js-collapsed').classes('d-none')).toBe(true);
      expect(wrapper.find('.js-expanded').classes('d-none')).toBe(false);
    });

    it('renders the field collapsed if there is no description yet', () => {
      description = '';
      createComponent();

      expect(wrapper.find('.js-collapsed').classes('d-none')).toBe(false);
      expect(wrapper.find('.js-expanded').classes('d-none')).toBe(true);
    });
  });
});
