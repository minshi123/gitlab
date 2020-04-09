import { shallowMount } from '@vue/test-utils';
import JiraImportProgress from '~/jira_import/components/jira_import_progress.vue';

const getImgAttribute = (attribute, wrapper) => wrapper.find('img').attributes(attribute);

const getParagraphTextAt = (index, wrapper) =>
  wrapper
    .findAll('p')
    .at(index)
    .text();

describe('JiraImportProgress', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(JiraImportProgress, {
      propsData: {
        illustration: 'illustration.svg',
        importInitiator: 'Jane Doe',
        importProject: 'JIRAPROJECT',
        importTime: '2020-04-08T12:17:25+00:00',
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('illustration', () => {
    it('is shown', () => {
      expect(getImgAttribute('src', wrapper)).toBe('illustration.svg');
    });

    it('has alt text', () => {
      expect(getImgAttribute('alt', wrapper)).toBe('Jira import in progress illustration');
    });
  });

  it('shows a heading to the user stating an import is in progress', () => {
    expect(wrapper.find('h4').text()).toBe('Import in progress');
  });

  it('shows who initiated the import', () => {
    expect(getParagraphTextAt(0, wrapper)).toBe('Import started by: Jane Doe');
  });

  it('shows the time of import', () => {
    expect(getParagraphTextAt(1, wrapper)).toBe('Time of import: Apr 8, 2020 12:17pm GMT+0000');
  });

  it('shows the project key of the import', () => {
    expect(getParagraphTextAt(2, wrapper)).toBe('Jira project: JIRAPROJECT');
  });

  it('contains button to view issues', () => {
    expect(wrapper.find('a').text()).toBe('View issues');
  });
});
