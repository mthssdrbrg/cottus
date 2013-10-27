# encoding: utf-8

require 'spec_helper'

module Cottus
  describe Client do
    describe '#initialize' do
      it 'accepts an array of hosts w/ ports' do
        client = described_class.new(['http://host1:123', 'http://host2:125'])
        expect(client.hosts).to eq ['host1', 'host2']
      end

      it 'accepts a connection string w/ ports' do
        client = described_class.new('http://host1:1255,http://host2:1255,http://host3:1255')
        expect(client.hosts).to eq ['host1', 'host2', 'host3']
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
          described_class.new('http://localhost:1234', strategy: strategy)
        end

        let :strategy do
          double(:strategy, new: strategy_impl)
        end

        let :strategy_impl do
          double(:strategy_impl)
        end

        it 'uses given strategy' do
          expect(client.strategy).to eq(strategy_impl)
        end

        context 'strategy options' do
          it 'passes explicit options when creating strategy' do
            client = described_class.new('http://localhost:1234', strategy: strategy, strategy_options: {timeouts: [1, 3, 5]})
            expect(strategy).to have_received(:new).with(anything, {timeouts: [1, 3, 5]})
          end
        end
      end
    end
  end
end
