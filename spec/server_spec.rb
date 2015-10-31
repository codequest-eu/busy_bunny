require 'spec_helper'

describe BusyBunny::Server do
  let(:conn1)    { double }
  let(:channel1) { double }
  let(:queue1)   { double }
  let(:queue2)   { double }

  before do
    expect(conn1).to receive(:create_channel) { channel1 }
    expect(channel1).to receive(:prefetch).with(1)
    expect(channel1).to receive(:queue).with('', durable: true) { queue1 }
  end

  context 'with one connection' do
    subject { described_class.new(conn1) }

    before do
      expect(channel1).to receive(:queue).with('', durable: true) { queue2 }
    end

    describe '#initialize' do
      it 'succeeds' do
        expect { subject }.to_not raise_error
      end
    end # describe '#initialize'

    describe '#respond' do
      let(:response) { 'response' }

      before do
        expect(queue2).to receive(:publish).with(response, instance_of(Hash))
      end

      it 'succeeds' do
        expect { subject.respond(response) }.to_not raise_error
      end
    end # describe '#respond'

    describe '#shutdown_gracefully' do
      before { expect(channel1).to receive(:close) }

      it 'succeeds' do
        expect { subject.shutdown_gracefully }.not_to raise_error
      end
    end # describe '#shutdown_gracefully'
  end # context 'with one connection'

  context 'with two connections' do
    let(:conn2) { double }
    let(:channel2) { double }

    subject { described_class.new(conn1, conn2) }

    before do
      expect(conn2).to receive(:create_channel) { channel2 }
      expect(channel2).to receive(:queue).with('', durable: true) { queue2 }
    end

    describe '#initialize' do
      it 'succeeds' do
        expect { subject }.to_not raise_error
      end
    end # describe '#initialize'

    describe '#shutdown_gracefully' do
      before { expect(channel1).to receive(:close) }
      before { expect(channel2).to receive(:close) }

      it 'succeeds' do
        expect { subject.shutdown_gracefully }.not_to raise_error
      end
    end # describe '#shutdown_gracefully'
  end # context 'with two connections'
end # describe BusyBunny::Server
