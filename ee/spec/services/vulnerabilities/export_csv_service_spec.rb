# frozen_string_literal: true

require 'spec_helper'

describe Vulnerabilities::ExportCsvService do
  let(:group) { create(:group) }
  let(:project) { create(:project, :public, group: group) }
  let!(:finding) { create(:vulnerabilities_occurrence, project: project) }
  let(:export_csv_service) { described_class.new(Vulnerabilities::Occurrence.all) }

  subject(:csv) { CSV.parse(export_csv_service.csv_data, headers: true) }

  it 'renders csv to string' do
    expect(export_csv_service.csv_data).to be_a String
  end

  it 'includes the columns required for import' do
    expect(csv.headers).to include('Scanner Type', 'Scanner Name', 'Vulnerability', 'Details', 'Additional Info',
                                    'Severity', 'CVE')
  end

  specify 'Scanner Type' do
    expect(csv[0]['Scanner Type']).to eq finding.report_type
  end

  specify 'Scanner Name' do
    expect(csv[0]['Scanner Name']).to eq finding.scanner_name
  end

  specify 'Vulnerability' do
    expect(csv[0]['Vulnerability']).to eq finding.name
  end

  specify 'Details' do
    expect(csv[0]['Details']).to eq finding.description
  end

  specify 'Additional Info' do
    expect(csv[0]['Additional Info']).to eq finding.metadata['message']
  end

  specify 'Severity' do
    expect(csv[0]['Severity']).to eq finding.severity
  end

  specify 'CVE' do
    expect(csv[0]['CVE']).to eq finding.metadata['cve']
  end
end
