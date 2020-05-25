# frozen_string_literal: true

require 'spec_helper'

describe Mutations::Discussions::Resolve do
  subject(:mutation) do
    described_class.new(object: nil, context: { current_user: user }, field: nil)
  end

  let_it_be(:project) { create(:project, :repository) }

  describe '#resolve' do
    subject do
      mutation.resolve(resolve_args)
    end

    let(:resolve_args) { { id: discussion.to_global_id.to_s } }
    let(:mutated_discussion) { subject[:discussion] }
    let(:errors) { subject[:errors] }

    shared_examples 'a working resolve method' do
      context 'when the user does not have permission' do
        let_it_be(:user) { create(:user) }

        it 'raises an error if the resource is not accessible to the user' do
          expect { subject }.to raise_error(
            Gitlab::Graphql::Errors::ResourceNotAvailable,
            "The resource that you are attempting to access does not exist or you don't have permission to perform this action"
          )
        end
      end

      context 'when the user has permission' do
        let_it_be(:user) { create(:user, developer_projects: [project]) }

        it 'resolves the discussion' do
          expect(mutated_discussion).to be_resolved
        end

        it 'returns empty errors' do
          expect(errors).to be_empty
        end

        context 'when discussion cannot be found' do
          let(:resolve_args) { { id: "#{discussion.to_global_id.to_s}foo" } }

          it 'raises an error' do
            expect { subject }.to raise_error(
              Gitlab::Graphql::Errors::ResourceNotAvailable,
              "The resource that you are attempting to access does not exist or you don't have permission to perform this action"
            )
          end
        end

        context 'when discussion is not a Discussion' do
          let(:discussion) { create(:note, noteable: noteable, project: project) }

          it 'raises an error' do
            expect { subject }.to raise_error(
              Gitlab::Graphql::Errors::ArgumentError,
              "#{discussion.to_global_id} is not a valid id for Discussion."
            )
          end
        end

        context 'when a `RecordNotSaved` error is encountered when calling the service' do
          before do
            allow_next_instance_of(::Discussions::ResolveService) do |service|
              allow(service).to receive(:execute).and_raise(ActiveRecord::RecordNotSaved, 'test error')
            end
          end

          it 'does not resolve the discussion' do
            expect(mutated_discussion).not_to be_resolved
          end

          it 'returns errors' do
            expect(errors).to contain_exactly('test error')
          end
        end
      end
    end

    context 'when discussion is on a merge request' do
      let_it_be(:noteable) { create(:merge_request, source_project: project) }
      let(:discussion) { create(:diff_note_on_merge_request, noteable: noteable, project: project).to_discussion }

      it_behaves_like 'a working resolve method'
    end

    context 'when discussion is on a design' do
      let_it_be(:noteable) { create(:design, :with_file, issue: create(:issue, project: project)) }
      let(:discussion) { create(:diff_note_on_design, noteable: noteable, project: project).to_discussion }

      it_behaves_like 'a working resolve method'
    end
  end
end
