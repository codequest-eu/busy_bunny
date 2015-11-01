require 'spec_helper'

module BusyBunny # rubocop:disable Style/Documentation
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
      let(:delivery_info) { double('del_info', delivery_tag: delivery_tag) }
      let(:request) { 'request' }

      before do
        expect(subject).to receive(:handle).with(request)
        expect(channel).to receive(:ack).with(delivery_tag)
      end

      it 'works' do
        expect { subject.send(:run_one, delivery_info, nil, request) }
          .to_not raise_error
      end
    end # describe '#run_one'
  end # describe Subscriber
end # module BusyBunny
