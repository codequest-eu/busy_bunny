module BusyBunny
  # Base is a common ancestor for all AMQP handlers: Subscribers, Publishers and
  # Servers alike.
  class Base
    # Base constructor.
    #
    # @param conn [Bunny::Session] AMQP connetion to use.
    # @param qname [String] Queue name.
    # @param prefetch = 1 Maximum number of messages to check out before sending
    #        an acknowledgement to the AMQP server.
    def initialize(conn, qname, prefetch: 1)
      @channel = Builder.build_channel(conn, prefetch)
      @queue = Builder.build_queue(@channel, qname)
    end

    # Close the underlying AMQP channel.
    def shutdown_gracefully
      @channel.close
    end
  end # class Base
end # module BusyBunny
