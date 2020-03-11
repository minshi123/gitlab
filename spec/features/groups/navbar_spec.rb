# frozen_string_literal: true

require 'spec_helper'

describe 'Group navbar' do
  include NavbarStructureHelper

  let(:user) { create(:user) }
  let(:group) { create(:group) }

  let(:analytics_nav_item) do
    {
      nav_item: _('Analytics'),
      nav_sub_items: [
        _('Contribution')
      ]
    }
  end

  let(:settings_nav_item) do
    {
      nav_item: _('Settings'),
      nav_sub_items: [
        _('General'),
        _('Projects'),
        _('CI / CD'),
        _('Webhooks'),
        _('Audit Events'),
        _('Usage Quotas')
      ]
    }
  end

  let(:structure) do
    [
      {
        nav_item: _('Group overview'),
        nav_sub_items: [
          _('Details'),
          _('Activity')
        ]
      },
      {
        nav_item: _('Issues'),
        nav_sub_items: [
          _('List'),
          _('Board'),
          _('Labels'),
          _('Milestones')
        ]
      },
      {
        nav_item: _('Merge Requests'),
        nav_sub_items: []
      },
      {
        nav_item: _('Kubernetes'),
        nav_sub_items: []
      },
      (analytics_nav_item if Gitlab.ee?),
      {
        nav_item: _('Members'),
        nav_sub_items: []
      }
    ]
  end

  before do
    group.add_maintainer(user)
    sign_in(user)
  end

  it_behaves_like 'verified navigation bar' do
    before do
      visit group_path(group)
    end
  end

  if Gitlab.ee?
    context 'when productivity analytics is available' do
      before do
        stub_licensed_features(productivity_analytics: true)

        analytics_nav_item[:nav_sub_items] << _('Productivity')

        visit group_path(group)
      end

      it_behaves_like 'verified navigation bar'
    end

    context 'when value stream analytics is available' do
      before do
        stub_licensed_features(cycle_analytics_for_groups: true)

        analytics_nav_item[:nav_sub_items] << _('Value Stream')

        visit group_path(group)
      end

      it_behaves_like 'verified navigation bar'
    end

    context 'when epics are available' do
      before do
        stub_licensed_features(epics: true)

        add_nav_item(
          structure: structure,
          before_nav_item_name: _('Group overview'),
          new_nav_item: {
            nav_item: _('Epics'),
            nav_sub_items: [
              _('List'),
              _('Roadmap')
            ]
          }
        )

        visit group_path(group)
      end

      it_behaves_like 'verified navigation bar'
    end

    context 'when the logged in user is the owner' do
      before do
        group.add_owner(user)

        add_nav_item(
          structure: structure,
          before_nav_item_name: _('Members'),
          new_nav_item: settings_nav_item
        )

        visit group_path(group)
      end

      it_behaves_like 'verified navigation bar'
    end

    context 'when security dashboard is available' do
      before do
        group.add_owner(user)

        stub_licensed_features(security_dashboard: true, group_level_compliance_dashboard: true)

        add_nav_item(
          structure: structure,
          before_nav_item_name: _('Merge Requests'),
          new_nav_item: {
            nav_item: _('Security & Compliance'),
            nav_sub_items: [
              _('Security'),
              _('Compliance')
            ]
          }
        )

        add_nav_item(
          structure: structure,
          before_nav_item_name: _('Members'),
          new_nav_item: settings_nav_item
        )

        visit group_path(group)
      end

      it_behaves_like 'verified navigation bar'
    end
  end
end
