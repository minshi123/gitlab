import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import IntegrationForm from './components/integration_form.vue';

export default el => {
  if (!el) {
    return null;
  }

  const {
    showActive: showActiveStr,
    activated: activatedStr,
    disabled: disabledStr,
    type,
    commitEvents: commitEventsStr,
    mergeRequestEvents: mergeRequestEventsStr,
    enableComments: enableCommentsStr,
    commentDetail,
  } = el.dataset;
  const showActive = parseBoolean(showActiveStr);
  const activated = parseBoolean(activatedStr);
  const disabled = parseBoolean(disabledStr);
  const commitEvents = parseBoolean(commitEventsStr);
  const mergeRequestEvents = parseBoolean(mergeRequestEventsStr);
  const enableComments = parseBoolean(enableCommentsStr);

  return new Vue({
    el,
    render(createElement) {
      return createElement(IntegrationForm, {
        props: {
          activeToggleProps: {
            showActive,
            initialActivated: activated,
            disabled,
          },
          type,
          triggerFieldsProps: {
            initialTriggerCommit: commitEvents,
            initialTriggerMergeRequest: mergeRequestEvents,
            initialEnableComments: enableComments,
            initialCommentDetail: commentDetail,
          },
        },
      });
    },
  });
};
