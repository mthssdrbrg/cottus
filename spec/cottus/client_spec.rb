# encoding: utf-8

require 'spec_helper'

module Cottus
  describe Client do
    describe '#initialize' do
      it 'accepts an array of hosts w/ ports' do
        client = described_class.new(['host1:123', 'host2:125'])
        expect(client.hosts).to eq ['host1:123', 'host2:125']
      end

      it 'accepts an array of hosts w/ port argument' do
        client = described_class.new(['host1', 'host2'], port: 1255)
        expect(client.hosts).to eq ['host1:1255', 'host2:1255']
      end

      it 'accepts a connection string w/ ports' do
        client = described_class.new('host1:1255,host2:1255,host3:1255')
        expect(client.hosts).to eq ['host1:1255', 'host2:1255', 'host3:1255']
      end

      it 'accepts a connection string w/ port argument' do
        client = described_class.new('host1,host2,host3', port: 1255)
        expect(client.hosts).to eq ['host1:1255', 'host2:1255', 'host3:1255']
      end
    end

    describe '#get' do
      let :client do
        described_class.new('http://localhost:1234,http://localhost:12345,http://localhost:12343')
      end

      it 'uses the first host for the first request' do
        request = stub_request(:get, 'http://localhost:1234/some/path?query=1')
        client.get '/some/path', query: { query: 1 }
        expect(request).to have_been_requested
      end

      it 'uses the second host for the second request' do
        stub_request(:get, 'http://localhost:1234/some/path?query=1')
        request = stub_request(:get, 'localhost:12345/some/path?query=1')
        2.times { client.get('/some/path', query: { query: 1 }) }
        expect(request).to have_been_requested
      end

      context 'exceptions' do
        context 'Timeout::Error' do
          it 'attempts to use each host until one succeeds' do
            stub_request(:get, 'http://localhost:1234/some/path?query=1').to_timeout
            stub_request(:get, 'http://localhost:12345/some/path?query=1').to_timeout
            request = stub_request(:get, 'http://localhost:12343/some/path?query=1')

            client.get '/some/path', query: { query: 1 }
            expect(request).to have_been_requested
          end

          it 'gives up after trying all hosts' do
            stub_request(:get, 'http://localhost:1234/some/path?query=1').to_timeout
            stub_request(:get, 'http://localhost:12345/some/path?query=1').to_timeout
            stub_request(:get, 'http://localhost:12343/some/path?query=1').to_timeout

            expect { client.get '/some/path', query: { query: 1 } }.to raise_error(Timeout::Error)
          end
        end

        [Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error|
          context "#{error}" do
            it 'attempts to use each host until one succeeds' do
              stub_request(:get, 'http://localhost:1234/some/path?query=1').to_raise(error)
              stub_request(:get, 'http://localhost:12345/some/path?query=1').to_raise(error)
              request = stub_request(:get, 'http://localhost:12343/some/path?query=1')

              client.get '/some/path', query: { query: 1 }
              expect(request).to have_been_requested
            end

            it 'gives up after trying all hosts' do
              stub_request(:get, 'http://localhost:1234/some/path?query=1').to_raise(error)
              stub_request(:get, 'http://localhost:12345/some/path?query=1').to_raise(error)
              stub_request(:get, 'http://localhost:12343/some/path?query=1').to_raise(error)

              expect { client.get '/some/path', query: { query: 1 } }.to raise_error(error)
            end
          end
        end
      end
    end

    describe '#post' do
      let :client do
        described_class.new('http://localhost:1234,http://localhost:12345,http://localhost:12343')
      end

      it 'uses the first host for the first request' do
        request = stub_request(:post, 'http://localhost:1234/some/path').with(body: 'query=1')
        client.post '/some/path', body: { query: 1 }
        expect(request).to have_been_requested
      end

      it 'uses the second host for the second request' do
        stub_request(:post, 'http://localhost:1234/some/path').with(body: 'query=1')
        request = stub_request(:post, 'http://localhost:12345/some/path').with(body: 'query=1')

        2.times { client.post('/some/path', body: { query: 1 }) }

        expect(request).to have_been_requested
      end

      context 'exceptions' do
        context 'Timeout::Error' do
          it 'attempts to use each host until one succeeds' do
            stub_request(:post, 'http://localhost:1234/some/path').with(body: 'query=1').to_timeout
            stub_request(:post, 'http://localhost:12345/some/path').with(body: 'query=1').to_timeout
            request = stub_request(:post, 'http://localhost:12343/some/path').with(body: 'query=1')

            client.post '/some/path', body: { query: 1 }
            expect(request).to have_been_requested
          end

          it 'gives up after trying all hosts' do
            stub_request(:post, 'http://localhost:1234/some/path').with(body: 'query=1').to_timeout
            stub_request(:post, 'http://localhost:12345/some/path').with(body: 'query=1').to_timeout
            stub_request(:post, 'http://localhost:12343/some/path').with(body: 'query=1').to_timeout

            expect { client.post '/some/path', body: { query: 1 } }.to raise_error(Timeout::Error)
          end
        end

        [Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error|
          context "#{error}" do
            it 'attempts to use each host until one succeeds' do
              stub_request(:post, 'http://localhost:1234/some/path').with(body: 'query=1').to_raise(error)
              stub_request(:post, 'http://localhost:12345/some/path').with(body: 'query=1').to_raise(error)
              request = stub_request(:post, 'http://localhost:12343/some/path').with(body: 'query=1')

              client.post '/some/path', body: { query: 1 }
              expect(request).to have_been_requested
            end

            it 'gives up after trying all hosts' do
              stub_request(:post, 'http://localhost:1234/some/path').with(body:  'query=1').to_raise(error)
              stub_request(:post, 'http://localhost:12345/some/path').with(body: 'query=1').to_raise(error)
              stub_request(:post, 'http://localhost:12343/some/path').with(body: 'query=1').to_raise(error)

              expect { client.post '/some/path', body: { query: 1 } }.to raise_error(error)
            end
          end
        end
      end
    end

    describe '#put' do
      let :client do
        described_class.new('http://localhost:1234,http://localhost:12345,http://localhost:12343')
      end

      it 'uses the first host for the first request' do
        request = stub_request(:put, 'http://localhost:1234/some/path').with(body: 'query=1')
        client.put '/some/path', body: { query: 1 }
        expect(request).to have_been_requested
      end

      it 'uses the second host for the second request' do
        stub_request(:put, 'http://localhost:1234/some/path').with(body: 'query=1')
        request = stub_request(:put, 'http://localhost:12345/some/path').with(body: 'query=1')

        2.times { client.put('/some/path', body: { query: 1 }) }

        expect(request).to have_been_requested
      end

      context 'exceptions' do
        context 'Timeout::Error' do
          it 'attempts to use each host until one succeeds' do
            stub_request(:put, 'http://localhost:1234/some/path').with(body: 'query=1').to_timeout
            stub_request(:put, 'http://localhost:12345/some/path').with(body: 'query=1').to_timeout
            request = stub_request(:put, 'http://localhost:12343/some/path').with(body: 'query=1')

            client.put '/some/path', body: { query: 1 }
            expect(request).to have_been_requested
          end

          it 'gives up after trying all hosts' do
            stub_request(:put, 'http://localhost:1234/some/path').with(body: 'query=1').to_timeout
            stub_request(:put, 'http://localhost:12345/some/path').with(body: 'query=1').to_timeout
            stub_request(:put, 'http://localhost:12343/some/path').with(body: 'query=1').to_timeout

            expect { client.put '/some/path', body: { query: 1 } }.to raise_error(Timeout::Error)
          end
        end

        [Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error|
          context "#{error}" do
            it 'attempts to use each host until one succeeds' do
              stub_request(:put, 'http://localhost:1234/some/path').with(body: 'query=1').to_raise(error)
              stub_request(:put, 'http://localhost:12345/some/path').with(body: 'query=1').to_raise(error)
              request = stub_request(:put, 'http://localhost:12343/some/path').with(body: 'query=1')

              client.put '/some/path', body: { query: 1 }
              expect(request).to have_been_requested
            end

            it 'gives up after trying all hosts' do
              stub_request(:put, 'http://localhost:1234/some/path').with(body:  'query=1').to_raise(error)
              stub_request(:put, 'http://localhost:12345/some/path').with(body: 'query=1').to_raise(error)
              stub_request(:put, 'http://localhost:12343/some/path').with(body: 'query=1').to_raise(error)

              expect { client.put '/some/path', body: { query: 1 } }.to raise_error(error)
            end
          end
        end
      end
    end
  end
end