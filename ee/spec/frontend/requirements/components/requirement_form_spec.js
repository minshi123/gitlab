import { shallowMount } from '@vue/test-utils';

import { GlFormGroup, GlFormInput } from '@gitlab/ui';
import RequirementForm from 'ee/requirements/components/requirement_form.vue';

import { mockRequirementsOpen } from '../mock_data';

const createComponent = ({ requirement = null, requirementRequestActive = false } = {}) =>
  shallowMount(RequirementForm, {
    propsData: {
      requirement,
      requirementRequestActive,
    },
  });

describe('RequirementForm', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed', () => {
    describe('saveButtonLabel', () => {
      it('returns string "Create requirement" when `requirement` prop is null', () => {
        expect(wrapper.vm.saveButtonLabel).toBe('Create requirement');
      });

      it('returns string "Save changes" when `requirement` prop is defined', () => {
        const wrapperWithRequirement = createComponent({
          requirement: mockRequirementsOpen[0],
        });

        expect(wrapperWithRequirement.vm.saveButtonLabel).toBe('Save changes');

        wrapperWithRequirement.destroy();
      });
    });
  });

  describe('methods', () => {
    describe('handleSave', () => {
      it('emits `save` event on component with `title` as param when form is in create mode', () => {
        wrapper.setData({
          title: 'foo',
        });

        wrapper.vm.handleSave();

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.emitted('save')).toBeTruthy();
          expect(wrapper.emitted('save')[0]).toEqual(['foo']);
        });
      });

      it('emits `save` event on component with object as param containing `iid` & `title` when form is in update mode', () => {
        const wrapperWithRequirement = createComponent({
          requirement: mockRequirementsOpen[0],
        });

        wrapperWithRequirement.vm.handleSave();

        return wrapperWithRequirement.vm.$nextTick(() => {
          expect(wrapperWithRequirement.emitted('save')).toBeTruthy();
          expect(wrapperWithRequirement.emitted('save')[0]).toEqual([
            {
              iid: mockRequirementsOpen[0].iid,
              title: mockRequirementsOpen[0].title,
            },
          ]);

          wrapperWithRequirement.destroy();
        });
      });
    });
  });

  describe('template', () => {
    it('renders gl-form-group component', () => {
      const glFormGroup = wrapper.find(GlFormGroup);

      expect(glFormGroup.exists()).toBe(true);
      expect(glFormGroup.attributes('label')).toBe('Requirement');
      expect(glFormGroup.attributes('label-for')).toBe('requirementTitle');
    });

    it('renders gl-form-input component', () => {
      const glFormInput = wrapper.find(GlFormInput);

      expect(glFormInput.exists()).toBe(true);
      expect(glFormInput.attributes('id')).toBe('requirementTitle');
      expect(glFormInput.attributes('placeholder')).toBe('Describe the requirement here');
    });

    it('renders gl-form-input component populated with `requirement.title` when `requirement` prop is defined', () => {
      const wrapperWithRequirement = createComponent({
        requirement: mockRequirementsOpen[0],
      });

      expect(wrapperWithRequirement.find(GlFormInput).attributes('value')).toBe(
        mockRequirementsOpen[0].title,
      );

      wrapperWithRequirement.destroy();
    });

    it('renders save button component', () => {
      const saveButton = wrapper.find('.js-requirement-save');

      expect(saveButton.exists()).toBe(true);
      expect(saveButton.text()).toBe('Create requirement');
    });

    it('renders cancel button component', () => {
      const cancelButton = wrapper.find('.js-requirement-cancel');

      expect(cancelButton.exists()).toBe(true);
      expect(cancelButton.text()).toBe('Cancel');
    });
  });
});
