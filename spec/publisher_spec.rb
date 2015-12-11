require 'spec_helper'

module BusyBunny
  describe Publisher do
    let(:channel) { double('channel') }
    let(:queue)   { double('queue') }
    let(:message) { double('message') }
    subject { MockPublisher.new(channel, queue) }

    describe '#publish' do
      let(:publish_exp) { expect(queue).to receive(:publish) }
      let(:default_opts) do
        { persistent: true, content_type: 'application/json' }
      end

      before { expect(channel).to receive(:open?).and_return(true) }

      context 'without priority' do
        before { publish_exp.with(message, default_opts) }

        it 'works' do
          expect { subject.publish(message) }.to_not raise_error
        end
      end # context 'without priority'

      context 'with priority' do
        let(:priority) { 42 }

        before do
          publish_exp.with(message, default_opts.merge(priority: priority))
        end

        it 'works' do
          expect { subject.publish(message, priority) }.to_not raise_error
        end
      end # context 'with priority'
    end # describe '#publish'
  end # describe Publisher
end # module BusyBunny
