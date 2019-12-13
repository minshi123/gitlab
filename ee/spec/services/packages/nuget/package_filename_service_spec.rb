# frozen_string_literal: true

require 'spec_helper'

describe Packages::Nuget::PackageFilenameService do
  let_it_be(:package_name) { 'DummyProject.DummyPackage' }
  let_it_be(:package_version) { '1.0.0' }

  describe '#execute' do
    subject { described_class.new(package_name, package_version).execute }

    it { is_expected.to eq('dummyproject.dummypackage.1.0.0.nupkg')}

    context 'with invalid package name' do
      let(:package_name) { '   ' }

      it { expect { subject }.to raise_error(ArgumentError, 'invalid package name or version') }
    end

    context 'with invalid package version' do
      let(:package_version) { '   ' }

      it { expect { subject }.to raise_error(ArgumentError, 'invalid package name or version') }
    end
  end
end
