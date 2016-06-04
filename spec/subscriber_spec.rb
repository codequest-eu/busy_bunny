require 'spec_helper'

module BusyBunny
  describe Subscriber do
    let(:channel) { double('channel') }
    let(:queue)   { double('queue') }
    let(:thread)  { double('thread') }

    subject { MockSubscriber.new(channel, queue, thread) }

    describe '#run_forever' do
      before { expect(Thread).to receive(:new).and_return(thread) }

      it 'succeeds' do
        expect { subject.run_forever }.not_to raise_error
      end
    end # describe '#run_forever'

    describe '#join' do
      before { expect(thread).to receive(:join) }

      it 'works' do
        expect { subject.join }.not_to raise_error
      end
    end # describe '#join'

    describe '#handle' do
      it 'raises NotImplementedError' do
        expect { subject.handle(nil) }.to raise_error NotImplementedError
      end
    end # describe '#handle'

    describe '#run' do # NOTE: testing private method
      before { expect(queue).to receive(:subscribe).with(instance_of(Hash)) }

      it 'works' do
        expect { subject.send(:run) }.not_to raise_error
      end
    end # describe '#run'

    describe '#run_one' do # # NOTE: testing private method
      let(:delivery_tag) { 'tag' }
      let(:delivery_info) do
        double(
          'delivery_info',
          delivery_tag: delivery_tag,
          redelivered?: redelivered
        )
      end
      let(:request) { 'request' }
      let(:properties) { double('message_properties') }

      shared_examples 'run_one_works' do
        it 'works' do
          expect { subject.send(:run_one, delivery_info, properties, request) }
            .to_not raise_error
        end
      end # shared_examples 'run_one_works'

      context 'when not redelivered' do
        let(:redelivered) { false }

        before do
          expect(channel).to receive(:ack).with(delivery_tag)
          expect(subject).to receive(:handle).with(request)
        end

        it_behaves_like 'run_one_works'
      end # context 'when not redelivered'

      context 'when redelivered' do
        let(:redelivered) { true }

        before do
          expect(subject)
            .to receive(:handle_redelivery)
            .with(delivery_info, properties, request)
        end

        it_behaves_like 'run_one_works'
      end # context 'when redelivered'
    end # describe '#run_one'
  end # describe Subscriber
end # module BusyBunny
