module BusyBunny
  # Publisher is a one-way, write-only connection to AMQP.
  class Publisher < Base
    # Publisher constructor.
    #
    # @param conn [Bunny::Session] AMQP connetion to use.
    # @param qname [String] Queue name.
    def initialize(conn, qname)
      super(conn, qname, prefetch: nil)
    end

    # Publish a message on the underlying queue.
    #
    # @param message [String] Raw message data.
    def publish(message)
      @channel.open unless @channel.open?
      @queue.publish(message, publish_opts)
    end

    private

    # Concrete implementations that want to change the options used for queue
    # publishing may override this for their specific requirements.
    #
    # @return [Hash]
    def publish_opts
      { persistent: true, content_type: 'application/json' }
    end
  end # class Publisher
end # module BusyBunny
