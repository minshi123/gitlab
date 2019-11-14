import Vue from 'vue';
import subscriptions from '~/sidebar/components/subscriptions/subscriptions.vue';
import eventHub from '~/sidebar/event_hub';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { mockTracking } from 'spec/helpers/tracking_helper';

describe('Subscriptions', function() {
  let vm;
  let Subscriptions;

  beforeEach(() => {
    Subscriptions = Vue.extend(subscriptions);
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('shows loading spinner when loading', () => {
    vm = mountComponent(Subscriptions, {
      loading: true,
      subscribed: undefined,
    });

    expect(vm.$refs.toggleButton.isLoading).toBe(true);
    expect(vm.$refs.toggleButton.$el.querySelector('.project-feature-toggle')).toHaveClass(
      'is-loading',
    );
  });

  it('is toggled "off" when currently not subscribed', () => {
    vm = mountComponent(Subscriptions, {
      subscribed: false,
    });

    expect(vm.$refs.toggleButton.$el.querySelector('.project-feature-toggle')).not.toHaveClass(
      'is-checked',
    );
  });

  it('is toggled "on" when currently subscribed', () => {
    vm = mountComponent(Subscriptions, {
      subscribed: true,
    });

    expect(vm.$refs.toggleButton.$el.querySelector('.project-feature-toggle')).toHaveClass(
      'is-checked',
    );
  });

  it('toggleSubscription method emits `toggleSubscription` event on eventHub and Component', () => {
    vm = mountComponent(Subscriptions, { subscribed: true });
    spyOn(eventHub, '$emit');
    spyOn(vm, '$emit');
    spyOn(vm, 'track');

    vm.toggleSubscription();

    expect(eventHub.$emit).toHaveBeenCalledWith('toggleSubscription', jasmine.any(Object));
    expect(vm.$emit).toHaveBeenCalledWith('toggleSubscription', jasmine.any(Object));
  });

  it('tracks the event when toggled', () => {
    vm = mountComponent(Subscriptions, { subscribed: true });
    const spy = mockTracking('_category_', vm.$el, spyOn);
    vm.toggleSubscription();

    expect(spy).toHaveBeenCalled();
  });

  it('onClickCollapsedIcon method emits `toggleSidebar` event on component', () => {
    vm = mountComponent(Subscriptions, { subscribed: true });
    spyOn(vm, '$emit');

    vm.onClickCollapsedIcon();

    expect(vm.$emit).toHaveBeenCalledWith('toggleSidebar');
  });

  it('notify component disabled when project_emails_disabled is set on', () => {
    vm = mountComponent(Subscriptions, {
      subscribed: true,
      projectEmailsDisabled: true,
      subscribeDisabledDescription: 'Notifications have been disabled',
    });

    expect(vm.$el.querySelector('span').getAttribute('data-original-title')).toBe(
      vm.subscribeDisabledDescription,
    );

    expect(vm.$el.querySelector('.issuable-header-text').textContent.trim()).toBe(
      vm.subscribeDisabledDescription,
    );
  });
});
