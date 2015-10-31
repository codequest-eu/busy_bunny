module BusyBunny
  # Server is a special case of Handler which not only takes requests from a
  # queue but puts back its responses on a different queue.
  class Server < Handler
    RESPONSE_QUEUE = ''

    # Server constructor. Server uses one or two connections (if provided).
    #
    # @param conn_pool [Array<Bunny::Session>] List of connections to use.
    def initialize(*conn_pool)
      super(*conn_pool)
      @single_queue = conn_pool.size < 2
      build_response_channel(@single_queue ? conn_pool.first : conn_pool[1])
    end

    # Put a message on the response channel. This is a helper method which is
    # going to be called from within a concrete implementation of 'handle'.
    #
    # @param response [String] Response as a raw string.
    def respond(response)
      @response_queue.publish(response, publish_opts)
    end

    # Closes underlying AMQP channels.
    def shutdown_gracefully
      super
      @response_channel.close unless @single_queue
    end

    private

    # Concrete implementations that want to change the options used for queue
    # publishing may override this for their specific requirements.
    def publish_opts
      { persistent: true, content_type: 'application/json' }
    end

    def build_response_channel(conn)
      @response_channel = @channel if @single_queue
      @response_channel ||= self.class.build_channel(conn)
      @response_queue = self.class.build_queue(
        @response_channel, self.class::RESPONSE_QUEUE)
    end
  end # class Server
end # module BusyBunny
