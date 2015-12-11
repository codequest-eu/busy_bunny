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
    def publish(message, priority = nil)
      @channel.open unless @channel.open?
      @queue.publish(message, opts_with_priority(priority))
    end

    private

    def opts_with_priority(priority = nil)
      return publish_opts unless priority
      publish_opts.merge(priority: priority)
    end

    # Concrete implementations that want to change the options used for queue
    # publishing may override this for their specific requirements.
    #
    # @return [Hash]
    def publish_opts
      { persistent: true, content_type: 'application/json' }
    end
  end # class Publisher
end # module BusyBunny
