# encoding: utf-8

require 'httparty'

module Cottus
  class Client
    include HTTParty

    attr_reader :hosts

    def initialize(hosts, options={})
      @hosts = parse_hosts(hosts, options[:port])
      @index = 0
    end

    def get(path, options={}, &block)
      tries = 0

      begin
        self.class.get(next_host + path, options, &block)
      rescue *VALID_EXCEPTIONS => e
        if tries >= @hosts.count
          raise e
        else
          tries += 1
          retry
        end
      end
    end

    private

    VALID_EXCEPTIONS = [
      Timeout::Error,
      Errno::ECONNREFUSED,
      Errno::ETIMEDOUT,
      Errno::ECONNRESET
    ].freeze

    def next_host
      h = @hosts[@index]
      @index = (@index + 1) % @hosts.count
      h
    end

    def parse_hosts(hosts, port=nil)
      hosts = hosts.split(',') if hosts.is_a?(String)
      hosts = hosts.map { |h| "#{h}:#{port}" } unless port.nil?
      hosts
    end
  end
end
