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

  class RoundRobinWithTimeoutsStrategy < RoundRobinStrategy
    def initialize(hosts, client, options={})
      super

      @timeouts = options[:timeouts] || [1, 3, 5]
    end

    def execute(meth, path, options={}, &block)
      tries = 0
      starting_host = host = next_host

      begin
        @client.send(meth, host + path, options, &block)
      rescue *VALID_EXCEPTIONS => e
        if tries < @timeouts.size
          sleep @timeouts[tries]
          tries += 1
          retry
        else
          host = next_host
          raise e if host == starting_host

          tries = 0
          retry
        end
      end
    end
  end
end
