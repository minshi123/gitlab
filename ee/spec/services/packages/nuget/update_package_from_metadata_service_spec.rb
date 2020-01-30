# frozen_string_literal: true

require 'spec_helper'

describe Packages::Nuget::UpdatePackageFromMetadataService do
  let!(:package) { create(:nuget_package) }
  let(:package_file) { package.package_files.first }
  let(:service) { described_class.new(package_file) }
  let(:package_name) { 'DummyProject.DummyPackage' }
  let(:package_version) { '1.0.0' }
  let(:package_file_name) { 'dummyproject.dummypackage.1.0.0.nupkg' }

  describe '#execute' do
    subject { service.execute }

    it 'updates package and package file' do
      expect { subject }
        .to change { ::Packages::Package.count }.by(0)
        .and change { ::Packages::PackageFile.count }.by(0)

      expect(package.reload.name).to eq(package_name)
      expect(package.version).to eq(package_version)
      last_package_file = package.package_files.last
      expect(last_package_file.file_name).to eq(package_file_name)
      expect(last_package_file.id).not_to eq(package_file.id)
    end

    context 'with exisiting package' do
      let!(:existing_package) { create(:nuget_package, project: package.project, name: package_name, version: package_version) }

      it 'link existing package and updates package file' do
        expect { subject }
          .to change { ::Packages::Package.count }.by(-1)
          .and change { ::Packages::PackageFile.count }.by(0)
          .and change { existing_package.package_files.count }.by(1)

        last_package_file = existing_package.reload.package_files.last
        expect(last_package_file.file_name).to eq(package_file_name)
        expect(last_package_file.id).not_to eq(package_file.id)
      end
    end

    context 'with package file not containing a nuspec file' do
      before do
        allow_any_instance_of(Zip::File).to receive(:glob).and_return([])
      end

      it 'raises an error' do
        expect { subject }.to raise_error(::Packages::Nuget::MetadataExtractionService::ExtractionError)
      end
    end

    context 'with package file with a blank package name' do
      before do
        allow(service).to receive(:package_name).and_return('')
      end

      it 'raises an error' do
        expect { subject }.to raise_error(::Packages::Nuget::UpdatePackageFromMetadataService::InvalidMetadataError)
      end
    end

    context 'with package file with a blank package version' do
      before do
        allow(service).to receive(:package_version).and_return('')
      end

      it 'raises an error' do
        expect { subject }.to raise_error(::Packages::Nuget::UpdatePackageFromMetadataService::InvalidMetadataError)
      end
    end
  end
end
