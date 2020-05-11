# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Elastic::BulkIndexer, :elastic do
  let_it_be(:issue) { create(:issue) }
  let_it_be(:other_issue) { create(:issue, project: issue.project) }

  let(:project) { issue.project }

  let(:logger) { ::Gitlab::Elasticsearch::Logger.build }

  subject(:indexer) { described_class.new(logger: logger) }

  let(:es_client) { indexer.client }

  let(:issue_as_ref) { ref(issue) }
  let(:issue_as_json_with_times) { issue.__elasticsearch__.as_indexed_json }
  let(:issue_as_json) { issue_as_json_with_times.except('created_at', 'updated_at') }

  let(:other_issue_as_ref) { ref(other_issue) }

  describe '#process' do
    it 'returns self' do
      expect(indexer.process(issue_as_ref)).to be(indexer)
    end

    it 'does not send a bulk request per call' do
      expect(es_client).not_to receive(:bulk)

      indexer.process(issue_as_ref)
    end

    it 'sends a bulk request if the max bulk request size is reached' do
      set_bulk_limit(indexer, 1)

      expect(es_client)
        .to receive(:bulk)
        .with(body: [kind_of(String), kind_of(String)])
        .and_return({})

      indexer.process(issue_as_ref)

      expect(indexer.failures).to be_empty
    end

    it 'sends a bulk request if adding another item would go over bulk limit' do
      set_bulk_limit(indexer, 400)
      indexer.process(issue_as_ref) # 376 bytes

      expect(es_client).to receive(:bulk) do |args|
        body_bytesize = args[:body].map(&:bytesize).reduce(:+)

        expect(body_bytesize).to be <= 400

        {}
      end

      indexer.process(issue_as_ref)

      expect(indexer.failures).to be_empty
    end
  end

  describe '#flush' do
    it 'completes a bulk' do
      indexer.process(issue_as_ref)

      expect(es_client)
        .to receive(:bulk)
        .with(body: [kind_of(String), kind_of(String)])
        .and_return({})

      expect(indexer.flush).to be_empty
    end

    it 'fails documents that elasticsearch refuses to accept' do
      # Indexes with uppercase characters are invalid
      expect(other_issue_as_ref.database_record.__elasticsearch__)
        .to receive(:index_name)
        .and_return('Invalid')

      indexer.process(issue_as_ref)
      indexer.process(other_issue_as_ref)

      expect(indexer.flush).to contain_exactly(other_issue_as_ref)
      expect(indexer.failures).to contain_exactly(other_issue_as_ref)

      refresh_index!

      expect(search_one(Issue)).to have_attributes(issue_as_json)
    end

    it 'fails all documents on exception' do
      expect(es_client).to receive(:bulk) { raise 'An exception' }

      indexer.process(issue_as_ref)
      indexer.process(other_issue_as_ref)

      expect(indexer.flush).to contain_exactly(issue_as_ref, other_issue_as_ref)
      expect(indexer.failures).to contain_exactly(issue_as_ref, other_issue_as_ref)
    end

    context 'indexing an issue' do
      it 'adds the issue to the index' do
        expect(indexer.process(issue_as_ref).flush).to be_empty

        refresh_index!

        expect(search_one(Issue)).to have_attributes(issue_as_json)
      end

      it 'reindexes an unchanged issue' do
        ensure_elasticsearch_index!

        expect(es_client).to receive(:bulk).and_call_original
        expect(indexer.process(issue_as_ref).flush).to be_empty
      end

      it 'reindexes a changed issue' do
        ensure_elasticsearch_index!
        issue.update!(title: 'new title')

        expect(issue_as_json['title']).to eq('new title')
        expect(indexer.process(issue_as_ref).flush).to be_empty

        refresh_index!

        expect(search_one(Issue)).to have_attributes(issue_as_json)
      end
    end

    context 'deleting an issue' do
      it 'removes the issue from the index' do
        ensure_elasticsearch_index!

        expect(issue_as_ref).to receive(:database_record).and_return(nil)
        expect(indexer.process(issue_as_ref).flush).to be_empty

        refresh_index!

        expect(search(Issue, '*').size).to eq(0)
      end

      it 'succeeds even if the issue is not present' do
        expect(issue_as_ref).to receive(:database_record).and_return(nil)
        expect(indexer.process(issue_as_ref).flush).to be_empty

        refresh_index!

        expect(search(Issue, '*').size).to eq(0)
      end
    end
  end

  def ref(record)
    Gitlab::Elastic::DocumentReference.build(record)
  end

  def stub_es_client(indexer, client)
    allow(indexer).to receive(:client) { client }
  end

  def set_bulk_limit(indexer, bytes)
    allow(indexer).to receive(:bulk_limit_bytes) { bytes }
  end

  def search(klass, text)
    klass.__elasticsearch__.search(text)
  end

  def search_one(klass)
    results = search(klass, '*')

    expect(results.size).to eq(1)

    results.first._source
  end
end
