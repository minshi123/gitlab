import { shallowMount } from '@vue/test-utils';
import Icon from '~/vue_shared/components/icon.vue';
import geoNodeHealthStatusComponent from 'ee/geo_nodes/components/geo_node_health_status.vue';
import {
  HEALTH_STATUS_ICON,
  HEALTH_STATUS_CLASS,
  HEALTH_STATUS_LABEL,
} from 'ee/geo_nodes/constants';
import { mockNodeDetails } from '../mock_data';

describe('GeoNodeHealthStatusComponent', () => {
  let wrapper;

  const defaultProps = {
    status: mockNodeDetails.health,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(geoNodeHealthStatusComponent, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findStatusPill = () => wrapper.find('.rounded-pill');

  describe.each`
    status         | healthCssClass                   | statusIconName                  | statusLabel
    ${'Healthy'}   | ${HEALTH_STATUS_CLASS.healthy}   | ${HEALTH_STATUS_ICON.healthy}   | ${HEALTH_STATUS_LABEL.healthy}
    ${'Unhealthy'} | ${HEALTH_STATUS_CLASS.unhealthy} | ${HEALTH_STATUS_ICON.unhealthy} | ${HEALTH_STATUS_LABEL.unhealthy}
    ${'Disabled'}  | ${HEALTH_STATUS_CLASS.disabled}  | ${HEALTH_STATUS_ICON.disabled}  | ${HEALTH_STATUS_LABEL.disabled}
    ${'Unknown'}   | ${HEALTH_STATUS_CLASS.unknown}   | ${HEALTH_STATUS_ICON.unknown}   | ${HEALTH_STATUS_LABEL.unknown}
    ${'Offline'}   | ${HEALTH_STATUS_CLASS.offline}   | ${HEALTH_STATUS_ICON.offline}   | ${HEALTH_STATUS_LABEL.offline}
  `(`computed properties`, ({ status, healthCssClass, statusIconName, statusLabel }) => {
    beforeEach(() => {
      createComponent({ status });
    });

    it(`returns ${healthCssClass} when status is ${status}`, () => {
      expect(wrapper.vm.healthCssClass).toBe(healthCssClass);
    });

    it('renders StatusPill correctly', () => {
      expect(findStatusPill().html()).toMatchSnapshot();
    });

    it(`returns ${statusIconName} when status is ${status}`, () => {
      expect(wrapper.vm.statusIconName).toBe(statusIconName);
    });

    it('renders Icon correctly', () => {
      expect(
        findStatusPill()
          .find(Icon)
          .html(),
      ).toMatchSnapshot();
    });

    it(`returns ${statusLabel} when status is ${status}`, () => {
      expect(wrapper.vm.statusLabel).toBe(statusLabel);
    });

    it('renders Label correctly', () => {
      expect(
        findStatusPill()
          .find('span')
          .html(),
      ).toMatchSnapshot();
    });
  });
});
