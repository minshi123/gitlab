import { GlNewButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import JiraImportForm from '~/jira_import/components/jira_import_form.vue';

describe('JiraImportForm', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(JiraImportForm);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });
});
