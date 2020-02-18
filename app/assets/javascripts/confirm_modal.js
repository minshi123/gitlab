import Vue from 'vue';
import ConfirmModal from '~/vue_shared/components/confirm_modal.vue';

const mountConfirmModal = button => {
  const attrs = {
    ...button.dataset,
  };

  return new Vue({
    render(h) {
      return h(ConfirmModal, { attrs });
    },
  }).$mount();
};

export default () => {
  document.getElementsByClassName('js-confirm-modal-button').forEach(button => {
    button.addEventListener('click', e => {
      e.preventDefault();

      mountConfirmModal(button);
    });
  });
};
