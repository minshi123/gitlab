# frozen_string_literal: true

require 'spec_helper'

describe Vulnerabilities::Stats do
  describe 'default_scope' do
    let_it_be(:project_1) { create(:project) }
    let_it_be(:vulnerability_1) { create(:vulnerability, :critical, project: project_1) }
    let_it_be(:vulnerability_2) { create(:vulnerability, :critical, project: project_1) }
    let_it_be(:vulnerability_3) { create(:vulnerability, :medium, project: project_1) }
    let_it_be(:vulnerability_4) { create(:vulnerability) }
    let_it_be(:vulnerability_5) { create(:vulnerability) }

    context 'when the relation is not scoped to a project' do
      subject(:stats) { described_class.all }

      it 'returns `vulnerability` records grouped by project_id for all projects' do
        expect(stats.to_a.length).to be(3)
      end
    end

    context 'when the relation is scoped to a project' do
      subject(:stats) { described_class.find_by(project: project_1) }

      it 'returns the stats only for scoping project', :aggregate_failures do
        expect(stats.info).to be(0)
        expect(stats.unknown).to be(0)
        expect(stats.low).to be(0)
        expect(stats.medium).to be(1)
        expect(stats.high).to be(0)
        expect(stats.critical).to be(2)
      end
    end
  end

  describe '.columns' do
    let(:expected_columns) { %w(project_id) }

    subject(:columns) { described_class.columns.map(&:name) }

    it 'only inherits `project_id` column from `vulnerabilities` table' do
      expect(columns).to eql(expected_columns)
    end
  end

  describe 'persistence' do
    subject(:save_stats) { stats.save }

    context 'when the object is a new record' do
      let(:stats) { described_class.new }

      it 'raises `ActiveRecord::ReadOnlyRecord` error' do
        expect { save_stats }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end

    context 'when the object is already persisted' do
      let(:vulnerability) { create(:vulnerability) }
      let(:stats) { described_class.find_by(project: vulnerability.project) }

      it 'raises `ActiveRecord::ReadOnlyRecord` error' do
        expect { save_stats }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end
  end

  describe '#grade' do
    let(:critical) { 1 }
    let(:high) { 1 }
    let(:medium) { 1 }
    let(:low) { 1 }
    let(:vulnerability_counts) { { critical: critical, high: high, medium: medium, low: low } }
    let(:stats) { described_class.new(vulnerability_counts) }

    subject { stats.grade }

    context 'when the highest severity is critical' do
      it { is_expected.to be(:f) }
    end

    context 'when the highest severity is high' do
      let(:critical) { 0 }

      it { is_expected.to be(:d) }
    end

    context 'when the highest severity is medium' do
      let(:critical) { 0 }
      let(:high) { 0 }

      it { is_expected.to be(:c) }
    end

    context 'when the highest severity is low' do
      let(:critical) { 0 }
      let(:high) { 0 }
      let(:medium) { 0 }

      it { is_expected.to be(:b) }
    end

    context 'when the highest severity is low' do
      let(:critical) { 0 }
      let(:high) { 0 }
      let(:medium) { 0 }
      let(:low) { 0 }

      it { is_expected.to be(:a) }
    end
  end
end
