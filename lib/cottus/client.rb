# encoding: utf-8

module Cottus
  class Client

    attr_reader :hosts, :strategy

    def initialize(hosts, options={})
      @hosts = parse_hosts(hosts)
      @strategy = create_strategy(options)
    end

    def get(path, options={}, &block)
      @strategy.execute(:get, path, options, &block)
    end

    def put(path, options={}, &block)
      @strategy.execute(:put, path, options, &block)
    end

    def post(path, options={}, &block)
      @strategy.execute(:post, path, options, &block)
    end

    def delete(path, options={}, &block)
      @strategy.execute(:delete, path, options, &block)
    end

    def head(path, options={}, &block)
      @strategy.execute(:head, path, options, &block)
    end

    def patch(path, options={}, &block)
      @strategy.execute(:patch, path, options, &block)
    end

    def options(path, options={}, &block)
      @strategy.execute(:options, path, options, &block)
    end

    def move(path, options={}, &block)
      @strategy.execute(:move, path, options, &block)
    end

    private

    def parse_hosts(hosts)
      hosts.is_a?(String) ? hosts.split(',') : hosts
    end

    def http
      HTTParty
    end

    def create_strategy(options)
      strategy_options = options[:strategy_options] || {}
      strategy_impl = options[:strategy] || RoundRobinStrategy
      strategy_impl.new(hosts, http, strategy_options)
    end
  end
end
