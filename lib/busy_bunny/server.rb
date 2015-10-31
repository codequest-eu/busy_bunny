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

    # Put a message on the response channel.
    # @param response [type] [description]
    # @param message_opts [type] [description]
    #
    # @return [type] [description]
    def respond(response, message_opts)
      @response_queue.publish(response, message_opts)
    end

    # Closes underlying AMQP channels.
    def shutdown_gracefully
      super
      @response_channel.close unless @single_queue
    end

    private

    def build_response_channel(conn)
      @response_channel = @channel if @single_queue
      @response_channel ||= self.class.build_channel(conn)
      @response_queue = self.class.build_queue(
        @response_channel, self.class::RESPONSE_QUEUE)
    end
  end # class Server
end # module BusyBunny
