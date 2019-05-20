require 'spec_helper'

describe Gitlab::Metrics::Samplers::UnicornSampler do
  subject { described_class.new(1.second) }

  describe '#sample' do
    let(:unicorn) { double('unicorn') }
    let(:raindrops) { double('raindrops') }
    let(:stats) { double('stats') }

    before do
      stub_const('Unicorn', unicorn)
      stub_const('Raindrops::Linux', raindrops)
      allow(raindrops).to receive(:unix_listener_stats).and_return({})
      allow(raindrops).to receive(:tcp_listener_stats).and_return({})
    end

    context 'unicorn listens on unix sockets' do
      let(:socket_address) { '/some/sock' }
      let(:sockets) { [socket_address] }

      before do
        allow(unicorn).to receive(:listener_names).and_return(sockets)
      end

      it 'samples socket data' do
        expect(raindrops).to receive(:unix_listener_stats).with(sockets)

        subject.sample
      end

      context 'stats collected' do
        before do
          allow(stats).to receive(:active).and_return('active')
          allow(stats).to receive(:queued).and_return('queued')
          allow(raindrops).to receive(:unix_listener_stats).and_return({ socket_address => stats })
        end

        it 'updates metrics type unix and with addr' do
          labels = { socket_type: 'unix', socket_address: socket_address }

          expect(subject.metrics[:unicorn_active_connections]).to receive(:set).with(labels, 'active')
          expect(subject.metrics[:unicorn_queued_connections]).to receive(:set).with(labels, 'queued')

          subject.sample
        end
      end
    end

    context 'unicorn listens on tcp sockets' do
      let(:tcp_socket_address) { '0.0.0.0:8080' }
      let(:tcp_sockets) { [tcp_socket_address] }
      before do
        allow(unicorn).to receive(:listener_names).and_return(tcp_sockets)
      end

      it 'samples socket data' do
        expect(raindrops).to receive(:tcp_listener_stats).with(tcp_sockets)

        subject.sample
      end

      context 'stats collected' do
        before do
          allow(stats).to receive(:active).and_return('active')
          allow(stats).to receive(:queued).and_return('queued')
          allow(raindrops).to receive(:tcp_listener_stats).and_return({ tcp_socket_address => stats })
        end

        it 'updates metrics type unix and with addr' do
          labels = { socket_type: 'tcp', socket_address: tcp_socket_address }

          expect(subject.metrics[:unicorn_active_connections]).to receive(:set).with(labels, 'active')
          expect(subject.metrics[:unicorn_queued_connections]).to receive(:set).with(labels, 'queued')

          subject.sample
        end
      end
    end

    context 'additional metrics' do
      let(:unicorn_workers) { 2 }

      before do
        allow(unicorn).to receive(:listener_names).and_return([""])
        allow(::Gitlab::Metrics::System).to receive(:cpu_time).and_return(3.14)
        allow(subject).to receive(:unicorn_workers_count).and_return(unicorn_workers)
      end

      it "sets additional metrics" do
        expect(subject.metrics[:unicorn_workers]).to receive(:set).with({}, unicorn_workers)

        subject.sample
      end
    end
  end

  describe '#start' do
    context 'when enabled' do
      before do
        allow(subject).to receive(:enabled?).and_return(true)
      end

      it 'creates new thread' do
        expect(Thread).to receive(:new)

        subject.start
      end
    end

    context 'when disabled' do
      before do
        allow(subject).to receive(:enabled?).and_return(false)
      end

      it "doesn't create new thread" do
        expect(Thread).not_to receive(:new)

        subject.start
      end
    end
  end
end
