# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'A Todoable that implements the pendingTodo interface' do
  include GraphqlHelpers

  let_it_be(:todoable) { create(:issue) }
  let_it_be(:current_user) { todoable.project.owner }

  let(:todoable_data) do
    graphql_data_at(:project, :issue)
  end

  let(:query) do
    <<~GQL
      {
        project(fullPath: "#{todoable.project.full_path}") {
          issue(iid: "#{todoable.iid}") {
            pendingTodo {
              #{all_graphql_fields_for('Todo', max_depth: 1)}
            }
          }
        }
      }
    GQL
  end

  def create_todo(state, user: current_user)
    create(:todo, state: state, user: user, target: todoable)
  end

  it 'returns a pending todo' do
    pending_todo = create_todo(:pending)

    post_graphql(query, current_user: current_user)

    expect(todoable_data).to include(
      'pendingTodo' => a_hash_including(
        'id' => global_id_of(pending_todo)
      )
    )
  end

  it 'does not return done todos, or pending todos for another user' do
    create_todo(:done)
    create_todo(:pending, user: create(:user))

    post_graphql(query, current_user: current_user)

    expect(todoable_data).to include('pendingTodo' => nil)
  end
end
