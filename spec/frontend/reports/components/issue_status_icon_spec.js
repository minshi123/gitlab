import { shallowMount } from '@vue/test-utils';
import ReportItem from '~/reports/components/issue_status_icon.vue';
import { STATUS_FAILED, STATUS_NEUTRAL, STATUS_SUCCESS } from '~/reports/constants';

describe('IssueStatusIcon', () => {
  let wrapper;

  const createComponent = ({ status }) => {
    wrapper = shallowMount(ReportItem, {
      propsData: {
        status,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it.each([STATUS_SUCCESS, STATUS_NEUTRAL, STATUS_FAILED])(
    'renders "%s" state correctly',
    status => {
      createComponent({ status });
      expect(wrapper.element).toMatchSnapshot();
    },
  );

  it('logs error if the value passed to the status prop is not a valid status', () => {
    const consoleErrorSpy = jest.spyOn(global.console, 'error').mockImplementationOnce(() => {});

    createComponent({ status: 'foo' });
    expect(consoleErrorSpy).toHaveBeenCalledTimes(1);
  });
});
