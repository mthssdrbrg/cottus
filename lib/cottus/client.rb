# encoding: utf-8

module Cottus
  class Client
    extend Forward

    forward :get, :put, :post, :delete, :head, :patch, :options, :move, :to => :@strategy, :through => :execute

    attr_reader :connections, :strategy

    def initialize(hosts, options={})
      @connections = create_connections(hosts)
      @strategy = create_strategy(options)
    end

    def hosts
      @connections.map(&:host)
    end

    private

    def create_connections(hosts)
      hosts = hosts.is_a?(String) ? hosts.split(',') : hosts
      hosts.map { |host| Connection.new(Excon.new(host)) }
    end

    def create_strategy(options)
      strategy_options = options[:strategy_options] || {}
      strategy_impl = options[:strategy] || RoundRobinStrategy
      strategy_impl.new(connections, strategy_options)
    end
  end
end
