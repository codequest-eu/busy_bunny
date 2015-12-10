module BusyBunny
  # Builder contains stateless helpers for building AMQP channels and queues.
  class Builder
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
    # @param queue_opts: [Hash] Queue declaration options.
    #
    # @return [Bunny::Queue]
    def self.build_queue(channel, name, queue_opts = {})
      channel.queue(name, queue_opts)
    end
  end # class Builder
end # module BusyBunny
