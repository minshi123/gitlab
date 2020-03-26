import SnippetVisibilityEdit from '~/snippets/components/snippet_visibility_edit.vue';
import { GlFormRadio } from '@gitlab/ui';
import { SNIPPET_VISIBILITY } from '~/snippets/constants';
import { mount, shallowMount } from '@vue/test-utils';

describe('Snippet Visibility Edit component', () => {
  let wrapper;
  let radios;
  const defaultHelpLink = '/foo/bar';
  const defaultVisibilityLevel = 0;
  const getWrapperAt = (wrapers, value) => wrapers.at(parseInt(value.at(0), 10));

  function findElements(sel) {
    return wrapper.findAll(sel);
  }

  function createComponent(
    { helpLink = defaultHelpLink, isProjectSnippet = false, value = defaultVisibilityLevel } = {},
    deep = false,
  ) {
    const method = deep ? mount : shallowMount;
    wrapper = method.call(this, SnippetVisibilityEdit, {
      propsData: {
        helpLink,
        isProjectSnippet,
        value,
      },
    });
    radios = findElements(GlFormRadio);
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('rendering', () => {
    it('matches the snapshot', () => {
      createComponent();
      expect(wrapper.element).toMatchSnapshot();
    });

    it.each`
      label                                | value
      ${SNIPPET_VISIBILITY.private.label}  | ${`0`}
      ${SNIPPET_VISIBILITY.internal.label} | ${`10`}
      ${SNIPPET_VISIBILITY.public.label}   | ${`20`}
    `('should render correct $label label', ({ label, value }) => {
      createComponent();
      const radio = getWrapperAt(radios, value);

      expect(radio.attributes('value')).toBe(value);
      expect(radio.text()).toContain(label);
    });

    describe('rendered help-text', () => {
      it.each`
        description                                | value   | label
        ${SNIPPET_VISIBILITY.private.description}  | ${`0`}  | ${SNIPPET_VISIBILITY.private.label}
        ${SNIPPET_VISIBILITY.internal.description} | ${`10`} | ${SNIPPET_VISIBILITY.internal.label}
        ${SNIPPET_VISIBILITY.public.description}   | ${`20`} | ${SNIPPET_VISIBILITY.public.label}
      `('should render correct $label description', ({ description, value }) => {
        createComponent({}, true);

        const help = getWrapperAt(findElements('.help-text'), value);

        expect(help.text()).toBe(description);
      });

      it('renders correct Private description for a project snippet', () => {
        createComponent({ isProjectSnippet: true }, true);

        const helpText = findElements('.help-text')
          .at(0)
          .text();

        expect(helpText).not.toContain(SNIPPET_VISIBILITY.private.description);
        expect(helpText).toBe(SNIPPET_VISIBILITY.private.description_project);
      });
    });
  });

  describe('functionality', () => {
    it('pre-selects correct option in the list', () => {
      const value = 10;
      const valueAsString = value.toString();

      createComponent({ value }, true);
      const radio = getWrapperAt(radios, valueAsString);
      expect(radio.find('input[type="radio"]').element.checked).toBe(true);
    });
  });
});
