# encoding: utf-8

module Cottus

  VALID_EXCEPTIONS = [
    Timeout::Error,
    Errno::ECONNREFUSED,
    Errno::ETIMEDOUT,
    Errno::ECONNRESET
  ].freeze

  class Strategy
    def initialize(connections, options={})
      @connections = connections
    end

    def execute(meth, path, options={}, &block)
      raise NotImplementedError, 'implement me in subclass'
    end
  end

  class RoundRobinStrategy < Strategy
    def initialize(connections, options={})
      super

      @index = 0
      @mutex = Mutex.new
    end

    def execute(meth, path, options={}, &block)
      tries = 0

      begin
        next_connection.send(meth, path, options, &block)
      rescue *VALID_EXCEPTIONS => e
        if tries >= @connections.count
          raise e
        else
          tries += 1
          retry
        end
      end
    end

    private

    def next_connection
      @mutex.synchronize do
        connection = @connections[@index]
        @index = (@index + 1) % @connections.count
        connection
      end
    end
  end

  class RetryableRoundRobinStrategy < RoundRobinStrategy
    def initialize(connections, options={})
      super

      @timeouts = options[:timeouts] || [1, 3, 5]
    end

    def execute(meth, path, options={}, &block)
      tries = 0
      starting_connection = connection = next_connection

      begin
        connection.send(meth, path, options, &block)
      rescue *VALID_EXCEPTIONS => e
        if tries < @timeouts.size
          sleep @timeouts[tries]
          tries += 1
          retry
        else
          connection = next_connection
          raise e if connection == starting_connection

          tries = 0
          retry
        end
      end
    end
  end
end
