import stateMaps from '~/vue_merge_request_widget/stores/state_maps';

stateMaps.stateToComponentMap.geoSecondaryNode = 'mr-widget-geo-secondary-node';
stateMaps.stateToComponentMap.polivyViolation = 'mr-widget-policy-violation';

export default {
  stateToComponentMap: stateMaps.stateToComponentMap,
  statesToShowHelpWidget: stateMaps.statesToShowHelpWidget,
};
