# frozen_string_literal: true

require 'spec_helper'

describe Packages::Nuget::MetadataExtractionService do
  let(:package_filepath) { 'ee/spec/fixtures/nuget/package.nupkg' }
  let(:service) { described_class.new(package_filepath) }

  describe '#execute' do
    subject { service.execute }

    context 'with valid package filepath' do
      it { is_expected.to eq(package_name: 'DummyProject.DummyPackage', package_version: '1.0.0') }
    end

    context 'with invalid package file id' do
      let(:package_filepath) { 'ee/foobar' }

      it { expect { subject }.to raise_error(::Packages::Nuget::MetadataExtractionService::ExtractionError, 'invalid package file') }
    end

    context 'with a 0 byte package file id' do
      let(:package_filepath) { Tempfile.new.path }

      it { expect { subject }.to raise_error(::Packages::Nuget::MetadataExtractionService::ExtractionError, 'invalid package file') }
    end

    context 'without the nuspec file' do
      before do
        allow_any_instance_of(Zip::File).to receive(:glob).and_return([])
      end

      it { expect { subject }.to raise_error(::Packages::Nuget::MetadataExtractionService::ExtractionError, 'nuspec file not found') }
    end

    context 'with a too big nuspec file' do
      before do
        allow_any_instance_of(Zip::File).to receive(:glob).and_return([OpenStruct.new(size: 6.megabytes)])
      end

      it { expect { subject }.to raise_error(::Packages::Nuget::MetadataExtractionService::ExtractionError, 'nuspec file too big') }
    end
  end
end
