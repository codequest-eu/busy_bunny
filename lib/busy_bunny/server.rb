module BusyBunny
  # Server is a two-way connection to AMQP whereby read and write end may exist
  # on totally separate servers, represented by conections.
  class Server < Subscriber
    # Server constructor. Server uses one or two connections (if provided).
    # While it takes a huge number of arguments concrete implementations may
    # have shorter constructors and hardcode things like queue names or prefetch
    # sizes in class constants.
    #
    # @param req_conn [Bunny::Session] Connection to use for requests.
    # @param res_conn [Bunny::Session] Connection to use for responses.
    # @param req_name [String] Queue name for requests.
    # @param res_name [type] Queue name for responses.
    # @param prefetch = 1 Maximum number of messages to check out before sending
    #        an acknowledgement to the AMQP server.
    def initialize(req_conn, res_conn, req_name, res_name, prefetch: 1)
      super(req_conn, req_name, prefetch)
      @publisher = publisher_class.new(res_conn, res_name)
    end

    # Put a message on the response channel. This is a helper method which is
    # going to be called from within a concrete implementation of 'handle'.
    #
    # @param response [String] Response as a raw string.
    def respond(response)
      @publisher.publish(response)
    end

    # Closes underlying AMQP channels.
    def shutdown_gracefully
      super
      @publisher.shutdown_gracefully
    end

    private

    # Publisher class to use. In most cases this won't need to be overridden.
    def publisher_class
      Publisher
    end
  end # class Server
end # module BusyBunny
