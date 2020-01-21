# frozen_string_literal: true

require 'spec_helper'

describe MicrosoftTeams::Notifier do
  subject { described_class.new(webhook_url) }

  let(:webhook_url) { 'https://example.gitlab.com/'}
  let(:header) { { 'Content-Type' => 'application/json' } }
  let(:options) do
    {
      title: 'JohnDoe4/project2',
      summary: '[[JohnDoe4/project2](http://localhost/namespace2/gitlabhq)] Issue [#1 Awesome issue](http://localhost/namespace2/gitlabhq/issues/1) opened by user6',
      activity: {
        title: 'Issue opened by user6',
        subtitle: 'in [JohnDoe4/project2](http://localhost/namespace2/gitlabhq)',
        text: '[#1 Awesome issue](http://localhost/namespace2/gitlabhq/issues/1)',
        image: 'http://someimage.com'
      },
      attachments: <<~EOS.chomp
        [ddd0f15a](http://gitlab.com/gitlab-org/gitlab-test/commit/ddd0f15ae83993f5cb66a927a28673882e99100b): Merge branch 'po-fix-test-env-path' into 'master'<br/>
        <br/>
        Correct test_env.rb path for adding branch<br/>
        <br/>
        See merge request gitlab-org/gitlab-test!38 - Stan Hu<br/>
        <br/>
        [2d1db523](http://localhost:3000/gitlab-org/gitlab-test/commit/2d1db523e11e777e49377cfb22d368deec3f0793): Correct test_env.rb path for adding branch<br/>
         - Paul Okstad<br/>
        <br/>
      EOS
    }
  end

  let(:body) do
    {
      'sections' => [
        {
          'activityTitle' => 'Issue opened by user6',
          'activitySubtitle' => 'in [JohnDoe4/project2](http://localhost/namespace2/gitlabhq)',
          'activityText' => '[#1 Awesome issue](http://localhost/namespace2/gitlabhq/issues/1)',
          'activityImage' => 'http://someimage.com'
        },
        {
          text: <<~EOS.chomp
            [ddd0f15a](http://gitlab.com/gitlab-org/gitlab-test/commit/ddd0f15ae83993f5cb66a927a28673882e99100b): Merge branch 'po-fix-test-env-path' into 'master'

            Correct test_env.rb path for adding branch

            See merge request gitlab-org/gitlab-test!38 - Stan Hu

            [2d1db523](http://localhost:3000/gitlab-org/gitlab-test/commit/2d1db523e11e777e49377cfb22d368deec3f0793): Correct test_env.rb path for adding branch
             - Paul Okstad
          EOS
        }
      ],
      'title' => 'JohnDoe4/project2',
      'summary' => '[[JohnDoe4/project2](http://localhost/namespace2/gitlabhq)] Issue [#1 Awesome issue](http://localhost/namespace2/gitlabhq/issues/1) opened by user6'
    }
  end

  describe '#ping' do
    before do
      stub_request(:post, webhook_url).with(body: JSON(body), headers: { 'Content-Type' => 'application/json' }).to_return(status: 200, body: "", headers: {})
    end

    it 'expects to receive successful answer' do
      expect(subject.ping(options)).to be true
    end
  end
end
