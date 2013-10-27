# encoding: utf-8

module Cottus
  class Connection
    extend Forward

    forward :get, :put, :post, :delete, :head, :patch, :options, :move, :to => :wrapper

    attr_reader :host

    def initialize(connection)
      @connection = connection
    end

    def host
      @connection.data[:host]
    end

    private

    def wrapper(verb, path, options={}, &blk)
      @connection.send(verb, options.merge({path: path}), &blk)
    end
  end
end
