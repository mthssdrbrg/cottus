# encoding: utf-8

module Cottus
  class Client

    attr_reader :hosts, :strategy

    def initialize(hosts, options={})
      @hosts = parse_hosts(hosts, options[:port])
      @strategy = create_strategy(options)
    end

    def get(path, options={}, &block)
      @strategy.execute(:get, path, options, &block)
    end

    def post(path, options={}, &block)
      @strategy.execute(:post, path, options, &block)
    end

    def put(path, options={}, &block)
      @strategy.execute(:put, path, options, &block)
    end

    def head(path, options={}, &block)
      @strategy.execute(:head, path, options, &block)
    end

    private

    def parse_hosts(hosts, port=nil)
      hosts = hosts.split(',') if hosts.is_a?(String)
      hosts = hosts.map { |h| "#{h}:#{port}" } unless port.nil?
      hosts
    end

    def http
      HTTParty
    end

    def create_strategy(options)
      strategy = (options[:strategy] || RoundRobinStrategy).new(hosts, http, options[:strategy_options])
    end
  end
end
