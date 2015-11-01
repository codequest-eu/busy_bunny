require 'spec_helper'

module BusyBunny # rubocop:disable Style/Documentation
  describe Builder do
    let(:chan) { double('channel') }

    describe '.build_channel' do
      let(:conn) { double('conn') }
      before     { expect(conn).to receive(:create_channel).and_return(chan) }

      shared_examples_for 'returns channel' do
        it 'returns channel' do
          expect(described_class.build_channel(conn, prefetch)).to eq chan
        end
      end # shared_examples_for 'returns channel'

      context 'without prefetch' do
        let(:prefetch) { nil }
        it_behaves_like 'returns channel'
      end # context 'without prefetch'

      context 'with prefetch' do
        let(:prefetch) { 1 }
        before         { expect(chan).to receive(:prefetch).with(prefetch) }
        it_behaves_like 'returns channel'
      end # context 'with prefetch'
    end # describe '.build_channel'

    describe '.build_queue' do
      let(:name) { 'name' }
      before { expect(chan).to receive(:queue).with(name, durable: true) }

      it 'works' do
        expect { described_class.build_queue(chan, name) }.to_not raise_error
      end
    end # describe '.build_queue'
  end # describe Builder
end # module BusyBunny
