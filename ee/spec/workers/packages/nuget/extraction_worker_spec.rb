# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::Nuget::ExtractionWorker, type: :worker do
  describe '#perform' do
    let!(:package) { create(:nuget_package) }
    let(:package_file) { package.package_files.first }
    let(:package_file_id) { package_file.id }

    let_it_be(:package_name) { 'DummyProject.DummyPackage' }
    let_it_be(:package_version) { '1.0.0' }
    let_it_be(:package_file_name) { 'dummyproject.dummypackage.1.0.0.nupkg' }

    subject { described_class.new.perform(package_file_id) }

    context 'with valid package file' do
      it 'updates package and package file' do
        expect { subject }
          .to not_change { Packages::Package.count }
          .and not_change { Packages::PackageFile.count }

        expect(package.reload.name).to eq(package_name)
        expect(package.version).to eq(package_version)
        expect(package_file.reload.file_name).to eq(package_file_name)
      end

      context 'with exisiting package' do
        let!(:existing_package) { create(:nuget_package, project: package.project, name: package_name, version: package_version) }

        it 'reuses existing package and updates package file' do
          expect { subject }
            .to change { Packages::Package.count }.by(-1)
            .and change { existing_package.reload.package_files.count }.by(1)
            .and not_change { Packages::PackageFile.count }

          expect(package_file.reload.file_name).to eq(package_file_name)
          expect(package_file.package).to eq(existing_package)
        end
      end
    end

    context 'with invalid package file id' do
      let(:package_file_id) { 5555 }

      it "doesn't update package and package file" do
        expect { subject }
          .to not_change { package.reload.name }
          .and not_change { package.version }
          .and not_change { package_file.reload.file_name }
      end
    end

    context 'with package file not containing a nuspec file' do
      before do
        allow_any_instance_of(Zip::File).to receive(:glob).and_return([])
      end

      it "doesn't update package and package file" do
        expect { subject }
          .to not_change { package.reload.name }
          .and not_change { package.version }
          .and not_change { package_file.reload.file_name }
      end
    end
  end
end
