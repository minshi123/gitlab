# frozen_string_literal: true

module QA
  module EE
    module Strategy
      extend self

      def extend_autoloads!
        require 'qa/ee'
      end

      def perform_before_hooks
        # We don't want to enter the infinite loop of calling `Runtime::Release.perform_before_hooks`
        # when we're currently running the `before(:suite)` RSpec hook defined in `Browser#configure!`.
        $performing_before_hooks = true

        # The login page could take some time to load the first time it is visited.
        # We visit the login page and wait for it to properly load only once before the tests.
        QA::Support::Retrier.retry_on_exception do
          QA::Runtime::Browser.visit(:gitlab, QA::Page::Main::Login)
        end

        return unless ENV['EE_LICENSE']

        EE::Resource::License.fabricate!(ENV['EE_LICENSE'])

        $performing_before_hooks = false
      end
    end
  end
end
