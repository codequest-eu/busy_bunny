require 'spec_helper'

describe BusyBunny::Handler do
  let(:conn)    { double }
  let(:channel) { double }
  let(:queue)   { double }

  before do
    expect(conn).to receive(:create_channel) { channel }
    expect(channel).to receive(:prefetch).with(1)
    expect(channel).to receive(:queue).with('', durable: true) { queue }
  end

  subject { described_class.new(conn) }

  describe '#initialize' do
    it 'succeeds' do
      expect { subject }.to_not raise_error
    end
  end # describe '#initialize'

  context 'within a thread' do
    let(:thread) { double }
    before { expect(Thread).to receive(:new).and_return(thread) }

    describe '#run_forever' do
      it 'succeeds' do
        expect { subject.run_forever }.not_to raise_error
      end
    end # describe '#run_forever'

    context 'with an active thread' do
      before { subject.run_forever }

      describe '#shutdown_gracefully' do
        before { expect(channel).to receive(:close) }

        it 'succeeds' do
          expect { subject.shutdown_gracefully }.not_to raise_error
        end
      end # describe '#shutdown_gracefully'

      describe '#join' do
        before { expect(thread).to receive(:join) }

        it 'succeeds' do
          expect { subject.join }.not_to raise_error
        end
      end # describe '#join'
    end # context 'with an active thread'
  end # context 'within a thread'

  # NOTE: #run is a private method.
  describe '#run' do
    before { expect(queue).to receive(:subscribe).with(instance_of(Hash)) }

    it 'succeeds' do
      expect { subject.send(:run) }.not_to raise_error
    end
  end # describe '#run'

  describe '#run_one' do
    let(:tag) { 'tag' }
    let(:request) { 'request' }
    let(:delivery_info) { double(delivery_tag: tag) }

    before do
      expect(subject).to receive(:handle).with(request)
      expect(channel).to receive(:ack).with(tag)
    end

    it 'succeeds' do
      expect { subject.send(:run_one, delivery_info, nil, request) }
        .to_not raise_error
    end
  end # describe '#run_one'
end # describe BusyBunny::Handler
