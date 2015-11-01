require 'spec_helper'

module BusyBunny # rubocop:disable Style/Documentation
  describe SubscriberPool do
    let(:conn)    { double('conn') }
    let(:builder) { double('builder') }
    let(:worker)  { double('worker') }

    subject { described_class.new(conn) }

    describe '#add_subscribers' do
      let(:call) { subject.add_subscribers(1) { |c| builder.build(c) } }
      before { expect(builder).to receive(:build).with([conn]) { worker } }

      it 'changes the size of the pool' do
        expect { call }.to change { subject.size }.from(0).to(1)
      end
    end # describe '#add_subscribers'

    context 'with mock pool' do
      subject { MockSubscriberPool.new([conn], [worker]) }

      describe '#run_forever' do
        before do
          expect(worker).to receive(:run_forever)
          expect(worker).to receive(:join)
        end

        it 'works' do
          expect { subject.run_forever }.to_not raise_error
        end
      end # describe '#run_forever'

      describe '#shutdown_gracefully' do
        before do
          expect(worker).to receive(:shutdown_gracefully)
          expect(conn).to receive(:close)
        end

        it 'works' do
          expect { subject.shutdown_gracefully }.to_not raise_error
        end
      end # describe '#shutdown_gracefully'
    end # context 'with mock pool'
  end # describe SubscriberPool
end # module BusyBunny
