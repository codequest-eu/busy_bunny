module BusyBunny
  # Handler is a basic worker using a single AMQP connection and channel for
  # one-way communication.
  class Handler
    PREFETCH_SIZE  = 1
    REQUEST_QUEUE  = ''

    # Handler constructor. Basic handler only utilizes one connection.
    #
    # @param conn_pool [Array<Bunny::Session>] List of connections to use.
    def initialize(*conn_pool)
      conn = conn_pool.first
      @channel = self.class.build_channel(conn, self.class::PREFETCH_SIZE)
      @queue = self.class.build_queue(@channel, self.class::REQUEST_QUEUE)
    end

    # Start the handler and run it forever. This call does not block.
    def run_forever
      @thread = Thread.new(&method(:run))
    end

    # Close the underlying AMQP channel. This results in the handler loop being
    # terminated and the thread's work coming to an end. At this stage the
    # Handler can not be reused.
    def shutdown_gracefully
      @channel.close
    end

    # Join the underlying thread. This is a blocking call.
    def join
      @thread.join
    end

    # Handle the message. This needs to be overwritten by concrete
    # implementations.
    #
    # @param _request [string] Raw request from the wire.
    def handle(_request)
      fail NotImplementedError
    end

    # Build a channel from connection.
    #
    # @param conn [Bunny::Session] Connection to build the channel on.
    # @param prefetch = nil [Fixnum] Number of messages to prefetch, if any.
    #
    # @return [Bunny::Channel]
    def self.build_channel(conn, prefetch = nil)
      conn.create_channel.tap { |c| c.prefetch(prefetch) if prefetch }
    end

    # Build a queue from channel.
    #
    # @param channel [Bunny::Channel] Channel for the queue to use.
    # @param name [String] Name of the queue.
    # @param durable: true [boolean] Whether to make this queue durable.
    #
    # @return [Bunny::Queue]
    def self.build_queue(channel, name, durable: true)
      channel.queue(name, durable: durable)
    end

    private

    def run
      @queue.subscribe(queue_opts, &method(:run_one))
    end

    def run_one(delivery_info, _properties, request)
      respond(request)
      @channel.ack(delivery_info.delivery_tag)
    end

    # Concrete implementations that want to change the options used for queue
    # subscription may override this for their specific requirements.
    def queue_opts
      { manual_ack: true, block: true }
    end
  end # class Handler
end # module BusyBunny
