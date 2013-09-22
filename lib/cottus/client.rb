# encoding: utf-8

module Cottus
  class Client
    extend Forward

    forward :get, :put, :post, :delete, :head, :patch, :options, :move

    attr_reader :hosts, :strategy

    def initialize(hosts, options={})
      @hosts = parse_hosts(hosts)
      @strategy = create_strategy(options)
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
