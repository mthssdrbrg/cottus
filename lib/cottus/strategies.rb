# encoding: utf-8

module Cottus

  VALID_EXCEPTIONS = [
    Timeout::Error,
    Errno::ECONNREFUSED,
    Errno::ETIMEDOUT,
    Errno::ECONNRESET
  ].freeze

  class Strategy
    def initialize(hosts, client, options={})
      @hosts, @client = hosts, client
    end

    def execute(meth, path, options={}, &block)
      raise NotImplementedError, 'implement me in subclass'
    end
  end

  class RoundRobinStrategy < Strategy
    def initialize(hosts, client, options={})
      super

      @index = 0
    end

    def execute(meth, path, options={}, &block)
      tries = 0

      begin
        @client.send(meth, next_host + path, options, &block)
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

    def next_host
      h = @hosts[@index]
      @index = (@index + 1) % @hosts.count
      h
    end
  end

  class TimeoutableStrategy < Strategy; end
end
