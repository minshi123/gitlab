# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(fullPath).releases()' do
  include GraphqlHelpers

  let_it_be(:stranger) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:reporter) { create(:user) }
  let_it_be(:developer) { create(:user) }

  let_it_be(:second_released_at) { Time.now }
  let_it_be(:first_released_at) { second_released_at - 1.day }

  let(:query) do
    graphql_query_for(:project, { fullPath: project.full_path },
    %{
      releases {
        count
        nodes {
          tagName
          tagPath
          name
          commit {
            sha
          }
          assets {
            count
            sources {
              nodes {
                url
              }
            }
          }
          evidences {
            nodes {
              sha
            }
          }
          links {
            selfUrl
            mergeRequestsUrl
            issuesUrl
          }
        }
      }
    })
  end

  let(:params_for_issues_and_mrs) { { scope: 'all', state: 'opened', release_tag: second_release.tag } }
  let(:post_query) { post_graphql(query, current_user: current_user) }

  let(:data) { graphql_data.dig('project', 'releases', 'nodes', 0) }

  before do
    stub_default_url_options(host: 'www.example.com')
  end

  shared_examples 'correct total count' do
    let(:data) { graphql_data.dig('project', 'releases') }

    before do
      post_query
    end

    it 'returns the total count' do
      expect(data['count']).to eq(project.releases.count)
    end
  end

  shared_examples 'full access to all repository-related fields' do
    describe 'repository-related fields' do
      before do
        post_query
      end

      it 'returns data for fields that are protected in private projects' do
        expected_sources = second_release.sources.map do |s|
          { 'url' => s.url }
        end

        expected_evidences = second_release.evidences.map do |e|
          { 'sha' => e.sha }
        end

        expect(data).to eq(
          'tagName' => second_release.tag,
          'tagPath' => project_tag_path(project, second_release.tag),
          'name' => second_release.name,
          'commit' => {
            'sha' => second_release.commit.sha
          },
          'assets' => {
            'count' => second_release.assets_count,
            'sources' => {
              'nodes' => expected_sources
            }
          },
          'evidences' => {
            'nodes' => expected_evidences
          },
          'links' => {
            'selfUrl' => project_release_url(project, second_release),
            'mergeRequestsUrl' => project_merge_requests_url(project, params_for_issues_and_mrs),
            'issuesUrl' => project_issues_url(project, params_for_issues_and_mrs)
          }
        )
      end
    end

    it_behaves_like 'correct total count'
  end

  shared_examples 'no access to any repository-related fields' do
    describe 'repository-related fields' do
      before do
        post_query
      end

      it 'does not return data for fields that expose repository information' do
        expect(data).to eq(
          'tagName' => nil,
          'tagPath' => nil,
          'name' => "Release-#{second_release.id}",
          'commit' => nil,
          'assets' => {
            'count' => second_release.assets_count(except: [:sources]),
            'sources' => {
              'nodes' => []
            }
          },
          'evidences' => {
            'nodes' => []
          },
          'links' => nil
        )
      end
    end

    it_behaves_like 'correct total count'
  end

  # editUrl is tested separately becuase its permissions
  # are slightly different than other release fields
  shared_examples 'access to editUrl' do
    let(:query) do
      graphql_query_for(:project, { fullPath: project.full_path },
        %{
          releases {
            nodes {
              links {
                editUrl
              }
            }
          }
        })
    end

    before do
      post_query
    end

    it 'returns editUrl' do
      expect(data).to eq(
        'links' => {
          'editUrl' => edit_project_release_url(project, second_release)
        }
      )
    end
  end

  shared_examples 'no access to editUrl' do
    let(:query) do
      graphql_query_for(:project, { fullPath: project.full_path },
        %{
          releases {
            nodes {
              links {
                editUrl
              }
            }
          }
        })
    end

    before do
      post_query
    end

    it 'does not return editUrl' do
      expect(data).to eq(
        'links' => {
          'editUrl' => nil
        }
      )
    end
  end

  shared_examples 'no access to any release data' do
    before do
      post_query
    end

    it 'returns nil' do
      expect(data).to eq(nil)
    end
  end

  describe "ensures that the correct data is returned based on the project's visibility and the user's access level" do
    context 'when the project is private' do
      let_it_be(:project) { create(:project, :repository, :private) }
      let_it_be(:first_release) { create(:release, :with_evidence, project: project, released_at: first_released_at) }
      let_it_be(:second_release) { create(:release, :with_evidence, project: project, released_at: second_released_at) }

      before_all do
        project.add_guest(guest)
        project.add_reporter(reporter)
        project.add_developer(developer)
      end

      context 'when the user is not logged in' do
        let(:current_user) { stranger }

        it_behaves_like 'no access to any release data'
      end

      context 'when the user has Guest permissions' do
        let(:current_user) { guest }

        it_behaves_like 'no access to any repository-related fields'
      end

      context 'when the user has Reporter permissions' do
        let(:current_user) { reporter }

        it_behaves_like 'full access to all repository-related fields'
        it_behaves_like 'no access to editUrl'
      end

      context 'when the user has Developer permissions' do
        let(:current_user) { developer }

        it_behaves_like 'full access to all repository-related fields'
        it_behaves_like 'access to editUrl'
      end
    end

    context 'when the project is public' do
      let_it_be(:project) { create(:project, :repository, :public) }
      let_it_be(:first_release) { create(:release, :with_evidence, project: project, released_at: first_released_at) }
      let_it_be(:second_release) { create(:release, :with_evidence, project: project, released_at: second_released_at) }

      before_all do
        project.add_guest(guest)
        project.add_reporter(reporter)
        project.add_developer(developer)
      end

      context 'when the user is not logged in' do
        let(:current_user) { stranger }

        it_behaves_like 'full access to all repository-related fields'
        it_behaves_like 'no access to editUrl'
      end

      context 'when the user has Guest permissions' do
        let(:current_user) { guest }

        it_behaves_like 'full access to all repository-related fields'
        it_behaves_like 'no access to editUrl'
      end

      context 'when the user has Reporter permissions' do
        let(:current_user) { reporter }

        it_behaves_like 'full access to all repository-related fields'
        it_behaves_like 'no access to editUrl'
      end

      context 'when the user has Developer permissions' do
        let(:current_user) { developer }

        it_behaves_like 'full access to all repository-related fields'
        it_behaves_like 'access to editUrl'
      end
    end
  end

  describe 'ensures that the release data can be contolled by a feature flag' do
    context 'when the graphql_release_data feature flag is disabled' do
      let_it_be(:project) { create(:project, :repository, :public) }
      let_it_be(:first_release) { create(:release, project: project, released_at: first_released_at) }
      let_it_be(:second_release) { create(:release, project: project, released_at: second_released_at) }

      let(:current_user) { developer }

      before do
        stub_feature_flags(graphql_release_data: false)

        project.add_developer(developer)
      end

      it_behaves_like 'no access to any release data'
    end
  end
end
