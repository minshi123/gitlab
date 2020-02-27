import { mount, shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { setHTMLFixture } from 'helpers/fixtures';
import waitForPromises from 'helpers/wait_for_promises';
import RelatedIssuesRoot from 'ee/related_issues/components/related_issues_root.vue';
import relatedIssuesService from 'ee/related_issues/services/related_issues_service';
import { linkedIssueTypesMap } from 'ee/related_issues/constants';
import {
  defaultProps,
  issuable1,
  issuable2,
} from 'jest/vue_shared/components/issue/related_issuable_mock_data';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';

jest.mock('~/flash');

describe('RelatedIssuesRoot', () => {
  let wrapper;
  let vm;
  let mock;

  beforeEach(() => {
    setHTMLFixture(`<div class="flash-text"></div>`);
    mock = new MockAdapter(axios);
    mock.onGet(defaultProps.endpoint).reply(200, []);
  });

  afterEach(() => {
    mock.restore();
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
      vm = null;
    }
  });

  const createComponent = (mountFn = mount) => {
    wrapper = mountFn(RelatedIssuesRoot, {
      propsData: defaultProps,
    });

    vm = wrapper.vm;

    return waitForPromises();
  };

  describe('methods', () => {
    describe('onRelatedIssueRemoveRequest', () => {
      beforeEach(() => {
        jest
          .spyOn(relatedIssuesService.prototype, 'fetchRelatedIssues')
          .mockReturnValue(Promise.reject());

        return createComponent().then(() => {
          vm.store.setRelatedIssues([issuable1]);
        });
      });

      it('remove related issue and succeeds', () => {
        mock.onDelete(issuable1.referencePath).reply(200, { issues: [] });

        vm.onRelatedIssueRemoveRequest(issuable1.id);

        return axios.waitForAll().then(() => {
          expect(vm.state.relatedIssues).toEqual([]);
        });
      });

      it('remove related issue, fails, and restores to related issues', () => {
        mock.onDelete(issuable1.referencePath).reply(422, {});

        vm.onRelatedIssueRemoveRequest(issuable1.id);

        return axios.waitForAll().then(() => {
          expect(vm.state.relatedIssues.length).toEqual(1);
          expect(vm.state.relatedIssues[0].id).toEqual(issuable1.id);
        });
      });
    });

    describe('onToggleAddRelatedIssuesForm', () => {
      beforeEach(() => createComponent(shallowMount));

      it('toggle related issues form to visible', () => {
        vm.onToggleAddRelatedIssuesForm();

        expect(vm.isFormVisible).toEqual(true);
      });

      it('show add related issues form to hidden', () => {
        vm.isFormVisible = true;

        vm.onToggleAddRelatedIssuesForm();

        expect(vm.isFormVisible).toEqual(false);
      });
    });

    describe('onPendingIssueRemoveRequest', () => {
      beforeEach(() =>
        createComponent().then(() => {
          vm.store.setPendingReferences([issuable1.reference]);
        }),
      );

      it('remove pending related issue', () => {
        expect(vm.state.pendingReferences.length).toEqual(1);

        vm.onPendingIssueRemoveRequest(0);

        expect(vm.state.pendingReferences.length).toEqual(0);
      });
    });

    describe('onPendingFormSubmit', () => {
      beforeEach(() => {
        jest
          .spyOn(relatedIssuesService.prototype, 'fetchRelatedIssues')
          .mockReturnValue(Promise.reject());

        return createComponent().then(() => {
          jest.spyOn(vm, 'processAllReferences');
          jest.spyOn(vm.service, 'addRelatedIssues');
          createFlash.mockClear();
        });
      });

      it('processes references before submitting', () => {
        const input = '#123';
        const linkedIssueType = linkedIssueTypesMap.RELATES_TO;
        const emitObj = {
          pendingReferences: input,
          linkedIssueType,
        };

        vm.onPendingFormSubmit(emitObj);

        expect(vm.processAllReferences).toHaveBeenCalledWith(input);
        expect(vm.service.addRelatedIssues).toHaveBeenCalledWith([input], linkedIssueType);
      });

      it('submit zero pending issue as related issue', () => {
        vm.store.setPendingReferences([]);
        vm.onPendingFormSubmit({});

        return waitForPromises().then(() => {
          expect(vm.state.pendingReferences.length).toEqual(0);
          expect(vm.state.relatedIssues.length).toEqual(0);
        });
      });

      it('submit pending issue as related issue', () => {
        mock.onPost(defaultProps.endpoint).reply(200, {
          issuables: [issuable1],
          result: {
            message: 'something was successfully related',
            status: 'success',
          },
        });

        vm.store.setPendingReferences([issuable1.reference]);
        vm.onPendingFormSubmit({});

        return waitForPromises().then(() => {
          expect(vm.state.pendingReferences.length).toEqual(0);
          expect(vm.state.relatedIssues.length).toEqual(1);
          expect(vm.state.relatedIssues[0].id).toEqual(issuable1.id);
        });
      });

      it('submit multiple pending issues as related issues', () => {
        mock.onPost(defaultProps.endpoint).reply(200, {
          issuables: [issuable1, issuable2],
          result: {
            message: 'something was successfully related',
            status: 'success',
          },
        });

        vm.store.setPendingReferences([issuable1.reference, issuable2.reference]);
        vm.onPendingFormSubmit({});

        return waitForPromises().then(() => {
          expect(vm.state.pendingReferences.length).toEqual(0);
          expect(vm.state.relatedIssues.length).toEqual(2);
          expect(vm.state.relatedIssues[0].id).toEqual(issuable1.id);
          expect(vm.state.relatedIssues[1].id).toEqual(issuable2.id);
        });
      });

      it('displays a message from the backend upon error', () => {
        const input = '#123';
        const message = 'error';

        mock.onPost(defaultProps.endpoint).reply(409, { message });
        vm.store.setPendingReferences([issuable1.reference, issuable2.reference]);

        expect(createFlash).not.toHaveBeenCalled();
        vm.onPendingFormSubmit(input);

        return waitForPromises().then(() => {
          expect(createFlash).toHaveBeenCalledWith(message);
        });
      });
    });

    describe('onPendingFormCancel', () => {
      beforeEach(() =>
        createComponent().then(() => {
          vm.isFormVisible = true;
          vm.inputValue = 'foo';
        }),
      );

      it('when canceling and hiding add issuable form', () => {
        vm.onPendingFormCancel();

        return vm.$nextTick().then(() => {
          expect(vm.isFormVisible).toEqual(false);
          expect(vm.inputValue).toEqual('');
          expect(vm.state.pendingReferences.length).toEqual(0);
        });
      });
    });

    describe('fetchRelatedIssues', () => {
      beforeEach(() => createComponent());

      it('sets isFetching while fetching', () => {
        vm.fetchRelatedIssues();

        expect(vm.isFetching).toEqual(true);

        return waitForPromises().then(() => {
          expect(vm.isFetching).toEqual(false);
        });
      });

      it('should fetch related issues', () => {
        mock.onGet(defaultProps.endpoint).reply(200, [issuable1, issuable2]);

        vm.fetchRelatedIssues();

        return waitForPromises().then(() => {
          expect(vm.state.relatedIssues.length).toEqual(2);
          expect(vm.state.relatedIssues[0].id).toEqual(issuable1.id);
          expect(vm.state.relatedIssues[1].id).toEqual(issuable2.id);
        });
      });
    });

    describe('onInput', () => {
      beforeEach(() => createComponent());

      it('fill in issue number reference and adds to pending related issues', () => {
        const input = '#123 ';
        vm.onInput({
          untouchedRawReferences: [input.trim()],
          touchedReference: input,
        });

        expect(vm.state.pendingReferences.length).toEqual(1);
        expect(vm.state.pendingReferences[0]).toEqual('#123');
      });

      it('fill in with full reference', () => {
        const input = 'asdf/qwer#444 ';
        vm.onInput({ untouchedRawReferences: [input.trim()], touchedReference: input });

        expect(vm.state.pendingReferences.length).toEqual(1);
        expect(vm.state.pendingReferences[0]).toEqual('asdf/qwer#444');
      });

      it('fill in with issue link', () => {
        const link = 'http://localhost:3000/foo/bar/issues/111';
        const input = `${link} `;
        vm.onInput({ untouchedRawReferences: [input.trim()], touchedReference: input });

        expect(vm.state.pendingReferences.length).toEqual(1);
        expect(vm.state.pendingReferences[0]).toEqual(link);
      });

      it('fill in with multiple references', () => {
        const input = 'asdf/qwer#444 #12 ';
        vm.onInput({ untouchedRawReferences: input.trim().split(/\s/), touchedReference: 2 });

        expect(vm.state.pendingReferences.length).toEqual(2);
        expect(vm.state.pendingReferences[0]).toEqual('asdf/qwer#444');
        expect(vm.state.pendingReferences[1]).toEqual('#12');
      });

      it('fill in with some invalid things', () => {
        const input = 'something random ';
        vm.onInput({ untouchedRawReferences: input.trim().split(/\s/), touchedReference: 2 });

        expect(vm.state.pendingReferences.length).toEqual(2);
        expect(vm.state.pendingReferences[0]).toEqual('something');
        expect(vm.state.pendingReferences[1]).toEqual('random');
      });
    });

    describe('onBlur', () => {
      beforeEach(() =>
        createComponent().then(() => {
          jest.spyOn(vm, 'processAllReferences').mockImplementation(() => {});
        }),
      );

      it('add any references to pending when blurring', () => {
        const input = '#123';

        vm.onBlur(input);

        expect(vm.processAllReferences).toHaveBeenCalledWith(input);
      });
    });

    describe('processAllReferences', () => {
      beforeEach(() => createComponent());

      it('add valid reference to pending', () => {
        const input = '#123';
        vm.processAllReferences(input);

        expect(vm.state.pendingReferences.length).toEqual(1);
        expect(vm.state.pendingReferences[0]).toEqual('#123');
      });

      it('add any valid references to pending', () => {
        const input = 'asdf #123';
        vm.processAllReferences(input);

        expect(vm.state.pendingReferences.length).toEqual(2);
        expect(vm.state.pendingReferences[0]).toEqual('asdf');
        expect(vm.state.pendingReferences[1]).toEqual('#123');
      });
    });
  });
});
