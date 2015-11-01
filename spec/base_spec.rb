require 'spec_helper'

module BusyBunny # rubocop:disable Style/Documentation
  describe Base do
    let(:conn)    { double('conn') }
    let(:channel) { double('channel') }
    let(:qname)   { double('qname') }

    describe '#initialize' do
      before do
        expect(Builder).to receive(:build_channel).with(conn, 1) { channel }
        expect(Builder).to receive(:build_queue).with(channel, qname)
      end

      it 'works' do
        expect { described_class.new(conn, qname) }.to_not raise_error
      end
    end # describe '#initialize'

    context 'with mock constructor' do
      subject { MockSubscriber.new(channel, nil, nil) } # nil queue and thread

      describe '#shutdown_gracefully' do
        before { expect(channel).to receive(:close) }

        it 'works' do
          expect { subject.shutdown_gracefully }.to_not raise_error
        end
      end # describe '#shutdown_gracefully'
    end # context 'with mock constructor'
  end # describe Base
end # module BusyBunny
