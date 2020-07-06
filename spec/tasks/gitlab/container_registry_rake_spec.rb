# frozen_string_literal: true

require 'rake_helper'

RSpec.describe 'gitlab:container_registry namespace rake tasks' do
  before :all do
    Rake.application.rake_require 'tasks/gitlab/container_registry'
  end

  describe '#configure' do
    subject { run_rake_task('gitlab:container_registry:configure') }

    it 'calls UpdateContainerRegistryInfoService' do
      expect_next_instance_of(UpdateContainerRegistryInfoService) do |service|
        expect(service).to receive(:execute)
      end

      subject
    end
  end
end
