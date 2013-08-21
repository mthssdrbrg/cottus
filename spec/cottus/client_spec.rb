# encoding: utf-8

require 'spec_helper'

module Cottus
  describe Client do
    describe '#initialize' do
      it 'accepts an array of hosts w/ ports' do
        client = described_class.new(['host1:123', 'host2:125'])
        expect(client.hosts).to eq ['host1:123', 'host2:125']
      end

      it 'accepts a connection string w/ ports' do
        client = described_class.new('host1:1255,host2:1255,host3:1255')
        expect(client.hosts).to eq ['host1:1255', 'host2:1255', 'host3:1255']
      end
    end

    context 'retry strategy' do
      context 'by default' do
        let :client do
          described_class.new('http://host1.com/')
        end

        it 'uses a simple round-robin strategy' do
          expect(client.strategy).to be_a RoundRobinStrategy
        end
      end

      context 'when given an explicit strategy' do
        let :client do
          described_class.new('http://localhost:1234', strategy: TimeoutableStrategy)
        end

        it 'uses given strategy' do
          expect(client.strategy).to be_a TimeoutableStrategy
        end

        context 'strategy options' do
          let :strategy do
            double(:strategy, new: nil)
          end

          it 'passes explicit options when creating strategy' do
            client = described_class.new('http://localhost:1234', strategy: strategy, strategy_options: {timeouts: [1, 3, 5]})
            expect(strategy).to have_received(:new).with(anything, anything, {timeouts: [1, 3, 5]})
          end
        end
      end
    end
  end
end
