require 'spec_helper'

module BusyBunny # rubocop:disable Style/Documentation
  describe Publisher do
    let(:channel) { double('channel') }
    let(:queue)   { double('queue') }
    let(:message) { double('message') }
    subject { MockPublisher.new(channel, queue) }

    describe '#publish' do
      before do
        expect(channel).to receive(:open?) { true }
        expect(queue).to receive(:publish).with(message, instance_of(Hash))
      end

      it 'works' do
        expect { subject.publish(message) }.to_not raise_error
      end
    end # describe '#publish'
  end # describe Publisher
end # module BusyBunny
