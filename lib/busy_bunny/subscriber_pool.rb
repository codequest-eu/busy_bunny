module BusyBunny
  # SubscriberPool takes care of managing the lifetime of Subscribers.
  class SubscriberPool
    # HandlerPool constructor.
    #
    # @param conn_pool [Array<Bunny::Session>] List of connections to use. Note
    #        that HandlerPool takes ownership of any connections passed to it
    #        and will take care of closing them.
    def initialize(*conn_pool)
      @conns = conn_pool
      @subscribers = []
    end

    # Add a number of managed subscribers based on a shared template.
    #
    # @param count [Fixnum] Number of subscribers to create.
    # @param &block [Callable<Array<Bunny::Session>>] Template to use when
    #        creating subscribers. Each template takes an array of connection
    #        (Bunny::Session) objects and is expected to return a Subscriber.
    def add_subscribers(count, &block)
      count.times { @subscribers << block.call(@conns) }
    end

    # @return [Fixnum] Total number of managed subscribers.
    def size
      @subscribers.size
    end

    # Start all of the managed subscribers and run them forever. This is a
    # blocking call and can only be unblocked by calling `shutdown_gracefully`
    # from either a different thread or a signal handler.
    def run_forever
      @subscribers.map(&:run_forever)
      @subscribers.map(&:join)
    end

    # Stop all the managed subscribers.
    def shutdown_gracefully
      @subscribers.map(&:shutdown_gracefully)
      @conns.map(&:close)
    end
  end # class HandlerPool
end # module BusyBunny
