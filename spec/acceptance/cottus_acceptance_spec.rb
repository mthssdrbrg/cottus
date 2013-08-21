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

    shared_examples 'load balancing' do
      it 'uses the first host for the first request' do
        request = stub_request(verb, 'http://localhost:1234/some/path')
        client.send(verb, '/some/path')
        expect(request).to have_been_requested
      end

      it 'uses the second host for the second request' do
        stub_request(verb, 'http://localhost:1234/some/path')
        request = stub_request(verb, 'localhost:12345/some/path')
        2.times { client.send(verb, '/some/path') }
        expect(request).to have_been_requested
      end
    end

    let :client do
      Client.new('http://localhost:1234,http://localhost:12345,http://localhost:12343')
    end

    describe '#get' do
      include_examples 'load balancing' do
        let(:verb) { :get }
      end

      include_examples 'exception handling' do
        let(:verb) { :get }
      end
    end

    describe '#post' do
      include_examples 'load balancing' do
        let(:verb) { :post }
      end

      include_examples 'exception handling' do
        let(:verb) { :post }
      end
    end

    describe '#put' do
      include_examples 'load balancing' do
        let(:verb) { :put }
      end

      include_examples 'exception handling' do
        let(:verb) { :put }
      end
    end

    describe '#head' do
      include_examples 'load balancing' do
        let(:verb) { :head }
      end

      include_examples 'exception handling' do
        let(:verb) { :head }
      end
    end

    describe '#patch' do
      include_examples 'load balancing' do
        let(:verb) { :patch }
      end

      include_examples 'exception handling' do
        let(:verb) { :patch }
      end
    end

    describe '#delete' do
      include_examples 'load balancing' do
        let(:verb) { :delete }
      end

      include_examples 'exception handling' do
        let(:verb) { :delete }
      end
    end

    describe '#move' do
      include_examples 'load balancing' do
        let(:verb) { :move }
      end

      include_examples 'exception handling' do
        let(:verb) { :move }
      end
    end

    describe '#options' do
      include_examples 'load balancing' do
        let(:verb) { :options }
      end

      include_examples 'exception handling' do
        let(:verb) { :options }
      end
    end

    describe '#copy' do
      pending do
        include_examples 'load balancing' do
          let(:verb) { :options }
        end

        include_examples 'exception handling' do
          let(:verb) { :options }
        end
      end
    end
  end
end
