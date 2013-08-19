# encoding: utf-8

require 'spec_helper'

module Cottus
  describe 'Client acceptance spec' do
    shared_examples 'exception handling' do
      context 'exceptions' do
        context 'Timeout::Error' do
          it 'attempts to use each host until one succeeds' do
            stub_request(verb, 'http://localhost:1234/some/path').to_timeout
            stub_request(verb, 'http://localhost:12345/some/path').to_timeout
            request = stub_request(verb, 'http://localhost:12343/some/path')

            client.send(verb, '/some/path')
            expect(request).to have_been_requested
          end

          it 'gives up after trying all hosts' do
            stub_request(verb, 'http://localhost:1234/some/path').to_timeout
            stub_request(verb, 'http://localhost:12345/some/path').to_timeout
            stub_request(verb, 'http://localhost:12343/some/path').to_timeout

            expect { client.send(verb, '/some/path') }.to raise_error(Timeout::Error)
          end
        end

        [Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error|
          context "#{error}" do
            it 'attempts to use each host until one succeeds' do
              stub_request(verb, 'http://localhost:1234/some/path').to_raise(error)
              stub_request(verb, 'http://localhost:12345/some/path').to_raise(error)
              request = stub_request(verb, 'http://localhost:12343/some/path')

              client.send(verb, '/some/path')
              expect(request).to have_been_requested
            end

            it 'gives up after trying all hosts' do
              stub_request(verb, 'http://localhost:1234/some/path').to_raise(error)
              stub_request(verb, 'http://localhost:12345/some/path').to_raise(error)
              stub_request(verb, 'http://localhost:12343/some/path').to_raise(error)

              expect { client.send(verb, '/some/path') }.to raise_error(error)
            end
          end
        end
      end
    end

    let :client do
      Client.new('http://localhost:1234,http://localhost:12345,http://localhost:12343')
    end

    describe '#get' do
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

      include_examples 'exception handling' do
        let(:verb) { :get }
      end
    end

    describe '#post' do
      it 'uses the first host for the first request' do
        request = stub_request(:post, 'http://localhost:1234/some/path')
        client.post '/some/path'
        expect(request).to have_been_requested
      end

      it 'uses the second host for the second request' do
        stub_request(:post, 'http://localhost:1234/some/path')
        request = stub_request(:post, 'http://localhost:12345/some/path')

        2.times { client.post '/some/path' }

        expect(request).to have_been_requested
      end

      include_examples 'exception handling' do
        let(:verb) { :post }
      end
    end

    describe '#put' do
      it 'uses the first host for the first request' do
        request = stub_request(:put, 'http://localhost:1234/some/path')
        client.put '/some/path'
        expect(request).to have_been_requested
      end

      it 'uses the second host for the second request' do
        stub_request(:put, 'http://localhost:1234/some/path')
        request = stub_request(:put, 'http://localhost:12345/some/path')

        2.times { client.put '/some/path' }

        expect(request).to have_been_requested
      end

      include_examples 'exception handling' do
        let(:verb) { :put }
      end
    end

    describe '#head' do
      it 'uses the first host for the first request' do
        request = stub_request(:head, 'http://localhost:1234/some/path?query=1')
        client.head '/some/path', query: { query: 1 }
        expect(request).to have_been_requested
      end

      it 'uses the second host for the second request' do
        stub_request(:head, 'http://localhost:1234/some/path?query=1')
        request = stub_request(:head, 'localhost:12345/some/path?query=1')
        2.times { client.head('/some/path', query: { query: 1 }) }
        expect(request).to have_been_requested
      end

      include_examples 'exception handling' do
        let(:verb) { :head }
      end
    end
  end
end
