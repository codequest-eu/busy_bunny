module BusyBunny
  # HandlerPool takes care of managing the lifetime of Handlers.
  class HandlerPool
    # HandlerPool constructor.
    #
    # @param conn_pool [Array<Bunny::Session>] List of connections to use.
    def initialize(*conn_pool)
      @conns = conn_pool
      @handlers = []
    end

    # Add a number of managed handlers based on a shared template.
    #
    # @param count [Fixnum] Number of handlers to create.
    # @param range = 0..-1 [Range] Range of managed connections to pass to each
    #        of the handlers.
    # @param &block [Callable<Array<Bunny::Session>>] template to use when
    #        creating handlers. Each template takes an array of connection
    #        (Bunny::Session) objects.
    def add_handlers(count, range = 0..-1, &block)
      count.times { @handlers << block.call(@conns.slice(range)) }
    end

    # @return [Fixnum] Total number of managed handlers.
    def size
      @handlers.size
    end

    # Start all of the managed handlers and run them forever. This is a blocking
    # call and can only be unblocked by calling `shutdown_gracefully` from
    # either a different thread or a signal handler.
    def run_forever
      @handlers.map(&:run_forever)
      @handlers.map(&:join)
    end

    # Stop all the managed handlers.
    def shutdown_gracefully
      @handlers.map(&:shutdown_gracefully)
      @conns.map(&:close)
    end
  end # class HandlerPool
end # module BusyBunny
