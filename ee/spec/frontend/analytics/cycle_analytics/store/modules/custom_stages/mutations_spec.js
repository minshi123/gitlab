import mutations from 'ee/analytics/cycle_analytics/store/modules/custom_stages/mutations';
import * as types from 'ee/analytics/cycle_analytics/store/modules/custom_stages/mutation_types';

import {
  rawIssueEvents as rawEvents,
  issueEvents as events,
  issueStage,
  planStage,
  codeStage,
  stagingStage,
  reviewStage,
  totalStage,
  startDate,
  endDate,
  customizableStagesAndEvents,
  selectedProjects,
} from '../../../mock_data';

let state = null;

describe('Custom stages mutations', () => {
  const initialData = { id: 10 };
  const errors = { id: 10 };
  beforeEach(() => {
    state = {};
  });

  afterEach(() => {
    state = null;
  });

  it.each`
    mutation                              | stateKey                   | value
    ${types.HIDE_FORM}                    | ${'isCreatingCustomStage'} | ${false}
    ${types.HIDE_FORM}                    | ${'isEditingCustomStage'}  | ${false}
    ${types.HIDE_FORM}                    | ${'formErrors'}            | ${null}
    ${types.HIDE_FORM}                    | ${'formInitialData'}       | ${null}
    ${types.SHOW_CREATE_FORM}             | ${'isCreatingCustomStage'} | ${true}
    ${types.SHOW_CREATE_FORM}             | ${'isEditingCustomStage'}  | ${false}
    ${types.SHOW_CREATE_FORM}             | ${'formErrors'}            | ${null}
    ${types.SHOW_CREATE_FORM}             | ${'formInitialData'}       | ${null}
    ${types.SHOW_EDIT_FORM}               | ${'isEditingCustomStage'}  | ${true}
    ${types.SHOW_EDIT_FORM}               | ${'isCreatingCustomStage'} | ${false}
    ${types.SHOW_EDIT_FORM}               | ${'formErrors'}            | ${null}
    ${types.CLEAR_FORM_ERRORS}            | ${'formErrors'}            | ${null}
    ${types.REQUEST_CREATE_STAGE}         | ${'formErrors'}            | ${null}
    ${types.REQUEST_CREATE_STAGE}         | ${'isSavingCustomStage'}   | ${true}
    ${types.RECEIVE_CREATE_STAGE_ERROR}   | ${'formErrors'}            | ${null}
    ${types.RECEIVE_CREATE_STAGE_SUCCESS} | ${'isSavingCustomStage'}   | ${false}
    ${types.RECEIVE_CREATE_STAGE_SUCCESS} | ${'formErrors'}            | ${null}
    ${types.RECEIVE_CREATE_STAGE_SUCCESS} | ${'formInitialData'}       | ${null}
  `('$mutation will set $stateKey=$value', ({ mutation, stateKey, value }) => {
    mutations[mutation](state);

    expect(state[stateKey]).toEqual(value);
  });

  it.each`
    mutation                            | payload            | expectedState
    ${types.SET_STAGE_EVENTS}           | ${{ rawEvents }}   | ${{ events }}
    ${types.RECEIVE_CREATE_STAGE_ERROR} | ${{ errors }}      | ${{ formErrors }}
    ${types.SHOW_EDIT_FORM}             | ${{ initialData }} | ${{ initialData }}
  `(
    '$mutation with payload $payload will update state with $expectedState',
    ({ mutation, payload, expectedState }) => {
      state = {
        selectedGroup: { fullPath: 'rad-stage' },
      };
      mutations[mutation](state, payload);

      expect(state).toMatchObject(expectedState);
    },
  );
});
