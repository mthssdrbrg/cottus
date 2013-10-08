# encoding: utf-8

module Cottus
  class Connection
    extend Forward

    forward :get, :put, :post, :delete, :head, :patch, :options, :move, :to => :wrapper

    attr_reader :host

    def initialize(*args)
      @http, @host = *args
    end

    private

    def wrapper(verb, path, options={}, &blk)
      @http.send(verb, @host + path, options, &blk)
    end
  end
end
