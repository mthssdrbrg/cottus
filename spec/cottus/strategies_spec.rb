# encoding: utf-8

require 'spec_helper'

module Cottus
  describe Strategy do
    let :strategy do
      described_class.new(['http://n1.com', 'http://n2.com'], http)
    end

    let :http do
      double(:http, meth: nil)
    end

    describe '#execute' do
      it 'raises a NotImplementedError' do
        expect { strategy.execute(:meth, '/some/path') }.to raise_error(NotImplementedError, 'implement me in subclass')
      end
    end
  end

  describe RoundRobinStrategy do
    let :strategy do
      described_class.new(hosts, http)
    end

    let :http do
      double(:http, meth: nil)
    end

    let :hosts do
      ['n1', 'n2', 'n3']
    end

    describe '#execute' do
      it 'uses the first host for the first request' do
        strategy.execute(:meth, '/some/path', query: { query: 1 })

        expect(http).to have_received(:meth).with('n1/some/path', query: { query: 1 }).once
      end

      it 'uses the second host for the second request' do
        2.times { strategy.execute(:meth, '/some/path', query: { query: 1 }) }

        expect(http).to have_received(:meth).with('n1/some/path', query: { query: 1 }).once
        expect(http).to have_received(:meth).with('n2/some/path', query: { query: 1 }).once
      end

      it 'uses each host in turn' do
        3.times { strategy.execute(:meth, '/some/path', query: { query: 1 }) }

        expect(http).to have_received(:meth).with('n1/some/path', query: { query: 1 }).once
        expect(http).to have_received(:meth).with('n2/some/path', query: { query: 1 }).once
        expect(http).to have_received(:meth).with('n3/some/path', query: { query: 1 }).once
      end

      context 'exceptions' do
        [Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error|
          context "#{error}" do
            it 'attempts to use each host until one succeeds' do
              ['n1', 'n2'].each { |h| http.stub(:meth).with("#{h}/some/path", {}).and_raise(error) }

              strategy.execute(:meth, '/some/path')
              expect(http).to have_received(:meth).with('n3/some/path', {})
            end

            it 'gives up after trying all hosts' do
              hosts.each { |h| http.stub(:meth).with("#{h}/some/path", {}).and_raise(error) }

              expect { strategy.execute(:meth, '/some/path') }.to raise_error(error)
            end
          end
        end
      end
    end
  end
end
