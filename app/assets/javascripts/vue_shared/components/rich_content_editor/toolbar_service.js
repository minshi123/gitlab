import Vue from 'vue';
import ToolbarItem from './toolbar_item.vue';

const createWrapper = (icon, className) => {
  const Component = Vue.extend(ToolbarItem);
  const instance = new Component({ propsData: { className, icon } });

  instance.$mount();
  return instance.$el;
};

// eslint-disable-next-line import/prefer-default-export
export const generateToolbarItem = config => {
  const { icon, class: className, event, command, tooltip, isDivider } = config;

  if (isDivider) {
    return 'divider';
  }

  return {
    type: 'button',
    options: {
      el: createWrapper(icon, className),
      event,
      command,
      tooltip,
    },
  };
};
