# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Middleware::Multipart do
  include MultipartHelpers

  describe '#call' do
    let(:app) { double(:app) }
    let(:middleware) { described_class.new(app) }
    let(:secret) { Gitlab::Workhorse.secret }
    let(:issuer) { 'gitlab-workhorse' }

    subject do
      env = post_env(
        rewritten_fields: rewritten_fields,
        params: params,
        secret: secret,
        issuer: issuer
      )
      middleware.call(env)
    end

    context 'with remote file mode params' do
      let(:mode) { :remote }

      it_behaves_like 'handling all upload parameters conditions'

      context 'and a path set' do
        include_context 'with one temporary file for multipart'

        let(:rewritten_fields) { { 'file' => path_for(uploaded_file) } }
        let(:params) { upload_parameters_for(key: 'file', filename: filename, remote_id: remote_id).merge('file.path' => '/should/not/be/read') }

        it 'builds an UploadedFile' do
          expect_uploaded_files(original_filename: filename, remote_id: remote_id, size: uploaded_file.size, params_path: %w(file))

          subject
        end
      end
    end

    context 'local file mode' do
      let(:mode) { :local }

      it_behaves_like 'handling all upload parameters conditions'

      # We are going to put the uploaded file in a tmp sub directory
      # This tmp sub directory will then be returned for each entry of multipart Handler#allowed_paths
      # Note that we are using the `with Dir.tmpdir stubbed to a tmp sub dir` context so that UploadedFile
      # will not automatically allow all files in tmp dir
      context 'when file is in' do
        context 'tmp dir' do
          include_context 'with one temporary file for multipart'

          it_behaves_like 'raising a bad request for insecure path used'
        end

        context 'file uploader root' do
          it_behaves_like 'handling uploaded file located in tmp sub dir' do
            before do
              allow(::FileUploader).to receive(:root).and_return(tmp_sub_dir)
            end
          end
        end

        context 'config uploads storage path' do
          it_behaves_like 'handling uploaded file located in tmp sub dir' do
            before do
              allow(Gitlab.config.uploads).to receive(:storage_path).and_return(tmp_sub_dir)
            end
          end
        end

        context 'CI artifact upload path' do
          it_behaves_like 'handling uploaded file located in tmp sub dir' do
            before do
              allow(JobArtifactUploader).to receive(:workhorse_upload_path).and_return(tmp_sub_dir)
            end
          end
        end

        context 'git lfs upload path' do
          it_behaves_like 'handling uploaded file located in tmp sub dir' do
            before do
              allow(LfsObjectUploader).to receive(:workhorse_upload_path).and_return(tmp_sub_dir)
            end
          end
        end

        context 'rails root uploads tmp folder' do
          it_behaves_like 'handling uploaded file located in tmp sub dir', path_in_tmp_sub_dir: 'public/uploads/tmp' do
            before do
              allow(Rails).to receive(:root).and_return(tmp_sub_dir)
            end
          end
        end

        context 'packages upload path' do
          using RSpec::Parameterized::TableSyntax

          where(:object_storage_enabled, :direct_upload_enabled, :shared_example_name) do
            false | true  | 'handling uploaded file located in tmp sub dir'
            false | false | 'handling uploaded file located in tmp sub dir'
            true  | true  | 'raising a bad request for insecure path used' # in this case Packages::PackageFileUploader#workhorse_upload_path is *not* in Handler#allowed_paths
            true  | false | 'handling uploaded file located in tmp sub dir'
          end

          with_them do
            before do
              stub_config(packages: {
                enabled: true,
                object_store: {
                  enabled: object_storage_enabled,
                  direct_upload: direct_upload_enabled
                },
                storage_path: '/any/dir'
              })
            end

            it_behaves_like params[:shared_example_name] do
              before do
                allow(Packages::PackageFileUploader).to receive(:workhorse_upload_path).and_return(tmp_sub_dir)
              end
            end
          end
        end
      end
    end

    context 'with dummy params in remote mode' do
      let(:rewritten_fields) { { 'file' => 'should/not/be/read' } }
      let(:params) { upload_parameters_for(key: 'file') }
      let(:mode) { :remote }

      context 'with an invalid secret' do
        let(:secret) { 'INVALID_SECRET' }

        it { expect { subject }.to raise_error(JWT::VerificationError) }
      end

      context 'with an invalid issuer' do
        let(:issuer) { 'INVALID_ISSUER' }

        it { expect { subject }.to raise_error(JWT::InvalidIssuerError) }
      end

      context 'with invalid rewritten field key' do
        invalid_keys = [
          '[file]',
          ';file',
          'file]',
          ';file]',
          'file]]',
          'file;;'
        ]

        invalid_keys.each do |invalid_key|
          context invalid_key do
            let(:rewritten_fields) { { invalid_key => 'should/not/be/read' } }

            it { expect { subject }.to raise_error(RuntimeError, "invalid field: \"#{invalid_key}\"") }
          end
        end
      end

      context 'with invalid key in parameters' do
        include_context 'with one temporary file for multipart'

        let(:rewritten_fields) { { 'file' => path_for(uploaded_file) } }
        let(:params) { upload_parameters_for(filepath: uploaded_filepath, key: 'wrong_key', filename: filename, remote_id: remote_id) }

        it 'builds no UploadedFile' do
          expect(app).to receive(:call) do |env|
            received_params = get_params(env)
            expect(received_params['file']).to be_nil
            expect(received_params['wrong_key']).to be_nil
          end

          expect { subject }.to raise_error(NoMethodError, "undefined method `close' for nil:NilClass")
        end
      end
    end
  end
end
