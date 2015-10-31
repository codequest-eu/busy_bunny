require 'spec_helper'

describe BusyBunny::HandlerPool do
  let(:conn1)    { double }
  let(:conn2)    { double }
  let(:builder)  { double }
  let(:add_call) { subject.add_handlers(1, 0..0) { |c| builder.build(c) } }
  let(:handler)  { double }

  before  { expect(builder).to receive(:build).with([conn1]) { handler } }
  subject { described_class.new(conn1, conn2) }

  describe '#add_handlers' do
    it 'changes the size of the handler pool' do
      expect { add_call }.to change { subject.size }.from(0).to(1)
    end
  end # describe '#add_handlers'

  context 'with a managed handler' do
    before { add_call }

    describe '#run_forever' do
      before do
        expect(handler).to receive(:run_forever)
        expect(handler).to receive(:join)
      end

      it 'succeeds' do
        expect { subject.run_forever }.to_not raise_error
      end
    end # describe '#run_forever'

    describe '#shutdown_gracefully' do
      before do
        expect(handler).to receive(:shutdown_gracefully)
        expect(conn1).to receive(:close)
        expect(conn2).to receive(:close)
      end

      it 'succeeds' do
        expect { subject.shutdown_gracefully }.to_not raise_error
      end
    end # describe '#shutdown_gracefully'
  end # context 'with a managed handler'
end # describe BusyBunny::HandlerPool
