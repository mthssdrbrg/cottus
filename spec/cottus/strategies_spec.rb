# encoding: utf-8

require 'spec_helper'

module Cottus
  describe Strategy do
    let :strategy do
      described_class.new(connections)
    end

    let :first do
      double(:http, get: nil)
    end

    let :second do
      double(:http, get: nil)
    end

    let :third do
      double(:http, get: nil)
    end

    let :connections do
      [first, second, third]
    end

    describe '#execute' do
      it 'raises a NotImplementedError' do
        expect { strategy.execute(:get, '/some/path') }.to raise_error(NotImplementedError, 'implement me in subclass')
      end
    end
  end

  shared_examples 'a round-robin strategy' do
    context 'with a single host' do
      let :connections do
        [first]
      end

      it 'uses the single host for the first request' do
        strategy.execute(:get, '/some/path', query: { query: 1 })

        expect(first).to have_received(:get).with('/some/path', query: { query: 1 }).once
      end

      it 'uses the single host for the second request' do
        2.times { strategy.execute(:get, '/some/path', query: { query: 1 }) }

        expect(first).to have_received(:get).with('/some/path', query: { query: 1 }).twice
      end
    end

    context 'with several hosts' do
      let :connections do
        [first, second, third]
      end

      it 'uses the first host for the first request' do
        strategy.execute(:get, '/some/path', query: { query: 1 })

        expect(first).to have_received(:get).with('/some/path', query: { query: 1 }).once
      end

      it 'uses the second host for the second request' do
        2.times { strategy.execute(:get, '/some/path', query: { query: 1 }) }

        expect(first).to have_received(:get).with('/some/path', query: { query: 1 }).once
        expect(second).to have_received(:get).with('/some/path', query: { query: 1 }).once
      end

      it 'uses each host in turn' do
        3.times { strategy.execute(:get, '/some/path', query: { query: 1 }) }

        expect(first).to have_received(:get).with('/some/path', query: { query: 1 }).once
        expect(second).to have_received(:get).with('/some/path', query: { query: 1 }).once
        expect(third).to have_received(:get).with('/some/path', query: { query: 1 }).once
      end
    end
  end

  describe RoundRobinStrategy do
    let :strategy do
      described_class.new(connections)
    end

    let :first do
      double(:http, get: nil)
    end

    let :second do
      double(:http, get: nil)
    end

    let :third do
      double(:http, get: nil)
    end

    describe '#execute' do
      context 'without exceptions' do
        it_behaves_like 'a round-robin strategy'
      end

      context 'with exceptions' do
        [Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error|
          context "when #{error} is raised" do
            context 'with a single host' do
              let :connections do
                [first]
              end

              it 'gives up' do
                connections.each { |conn| conn.stub(:get).with('/some/path', {}).and_raise(error) }

                expect { strategy.execute(:get, '/some/path') }.to raise_error(error)
              end
            end

            context 'with several hosts' do
              let :connections do
                [first, second, third]
              end

              it 'attempts to use each host until one succeeds' do
                [first, second].each { |conn| conn.stub(:get).with('/some/path', {}).and_raise(error) }

                strategy.execute(:get, '/some/path')
                expect(third).to have_received(:get).with('/some/path', {})
              end

              it 'gives up after trying all hosts' do
                connections.each { |conn| conn.stub(:get).with('/some/path', {}).and_raise(error) }

                expect { strategy.execute(:get, '/some/path') }.to raise_error(error)
              end
            end
          end
        end
      end
    end
  end

  describe RetryableRoundRobinStrategy do
    let :strategy do
      described_class.new(connections, timeouts: [0, 0, 0])
    end

    let :first do
      double(:http, get: nil)
    end

    let :second do
      double(:http, get: nil)
    end

    let :third do
      double(:http, get: nil)
    end

    describe '#execute' do
      context 'without any exceptions' do
        it_behaves_like 'a round-robin strategy'
      end

      context 'with exceptions' do
        [Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error|
          context "when #{error} is raised" do
            context 'with a single host' do
              let :connections do
                [first]
              end

              it 'uses the single host for three consecutive exceptions' do
                expect(first).to receive(:get).with('/some/path', {}).exactly(3).times.and_raise(error)
                expect(first).to receive(:get).with('/some/path', {}).once
                expect(strategy).to receive(:sleep).with(0).exactly(3).times

                strategy.execute(:get, '/some/path')
              end

              it 'gives up after three retries' do
                expect(first).to receive(:get).with('/some/path', {}).exactly(4).times.and_raise(error)
                expect(strategy).to receive(:sleep).with(0).exactly(3).times

                expect { strategy.execute(:get, '/some/path') }.to raise_error(error)
              end
            end

            context 'with several hosts' do
              let :connections do
                [first, second, third]
              end

              it 'uses the same host for three consecutive exceptions' do
                expect(first).to receive(:get).with('/some/path', {}).exactly(3).times.and_raise(error)
                expect(first).to receive(:get).with('/some/path', {}).once
                expect(strategy).to receive(:sleep).with(0).exactly(3).times

                strategy.execute(:get, '/some/path')
              end

              it 'switches host after three retries' do
                expect(first).to receive(:get).with('/some/path', {}).exactly(4).times.and_raise(error)
                expect(second).to receive(:get).with('/some/path', {}).once
                expect(strategy).to receive(:sleep).with(0).exactly(3).times

                strategy.execute(:get, '/some/path')
              end
            end
          end
        end
      end
    end
  end
end
