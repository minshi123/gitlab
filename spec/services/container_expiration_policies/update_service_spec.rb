# frozen_string_literal: true

require 'spec_helper'

describe ContainerExpirationPolicies::UpdateService do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:project, reload: true) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:params) { { cadence: '3month', keep_n: 100, older_than: '90d' } }

  let(:container_expiration_policy) { project.container_expiration_policy.reload }

  describe '#execute' do
    subject { described_class.new(container: project, current_user: user, params: params).execute }

    RSpec.shared_examples 'updating the attributes' do
      it 'updates the container expiration policy' do
        expect { subject }
          .to change { ContainerExpirationPolicy.count }.by(0)
          .and change { container_expiration_policy.cadence }.from('7d').to('3month')
          .and change { container_expiration_policy.keep_n }.from(nil).to(100)
          .and change { container_expiration_policy.older_than }.from(nil).to('90d')
      end
    end

    RSpec.shared_examples 'not creating the container expiration policy' do
      it "doesn't create the container expiration policy" do
        expect { subject }.not_to change { ContainerExpirationPolicy.count }
      end
    end

    RSpec.shared_examples 'returning a success' do
      it 'returns a success' do
        result = subject

        expect(result.keys).to contain_exactly(:container_expiration_policy, :status)
        expect(result[:container_expiration_policy]).to be_present
        expect(result[:status]).to eq(:success)
      end
    end

    RSpec.shared_examples 'returning an error' do |message, http_status|
      it 'returns an error' do
        result = subject

        expect(result.keys).to contain_exactly(:message, :http_status, :status)
        expect(result[:message]).to eq(message)
        expect(result[:status]).to eq(:error)
        expect(result[:http_status]).to eq(http_status)
      end
    end

    RSpec.shared_examples 'updating the container expiration policy' do
      context 'with existing container expiration policy' do
        it "doesn't create a new container expiration policy" do
          expect { subject }.not_to change { ContainerExpirationPolicy.count }
        end

        it_behaves_like 'updating the attributes'

        it_behaves_like 'returning a success'

        context 'with invalid params' do
          let_it_be(:params) { { cadence: '20d' } }

          it_behaves_like 'not creating the container expiration policy'

          it "doesn't update the cadence" do
            expect { subject }
              .not_to change { container_expiration_policy.reload.cadence }
          end

          it_behaves_like 'returning an error', 'Cadence is not included in the list', 400
        end
      end

      context 'without existing container expiration policy' do
        let_it_be(:project, reload: true) { create(:project, :without_container_expiration_policy) }

        it 'creates a new container expiration policy' do
          expect { subject }
            .to change { project.container_expiration_policy.present? }.from(false).to(true)
            .and change { ContainerExpirationPolicy.count }.by(1)
        end

        it 'sets the proper attributes' do
          subject

          expect(container_expiration_policy.cadence).to eq('3month')
          expect(container_expiration_policy.keep_n).to eq(100)
          expect(container_expiration_policy.older_than).to eq('90d')
        end

        it_behaves_like 'returning a success'
      end
    end

    RSpec.shared_examples 'denying access to container expiration policy' do
      context 'with existing container expiration policy' do
        it_behaves_like 'not creating the container expiration policy'

        it_behaves_like 'returning an error', 'Access Denied', 403
      end

      context 'without existing container expiration policy' do
        let_it_be(:project, reload: true) { create(:project, :without_container_expiration_policy) }

        it_behaves_like 'not creating the container expiration policy'

        it_behaves_like 'returning an error', 'Access Denied', 403
      end
    end

    where(:user_role, :shared_examples_name) do
      :maintainer | 'updating the container expiration policy'
      :developer  | 'updating the container expiration policy'
      :reporter   | 'denying access to container expiration policy'
      :guest      | 'denying access to container expiration policy'
      :anonymous  | 'denying access to container expiration policy'
    end

    with_them do
      before do
        project.send("add_#{user_role}", user) unless user_role == :anonymous
      end

      it_behaves_like params[:shared_examples_name]
    end
  end
end
