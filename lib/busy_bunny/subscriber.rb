module BusyBunny
  # Subscriber is a one-way, read-only connection to AMQP.
  class Subscriber < Base
    # Start the handler and run it forever. This call does not block.
    def run_forever
      @thread = Thread.new(&method(:run))
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

    private

    def run
      @queue.subscribe(subscription_opts, &method(:run_one))
    end

    def run_one(delivery_info, _properties, request)
      handle(request)
      @channel.ack(delivery_info.delivery_tag)
    end

    # Concrete implementations that want to change the options used for queue
    # subscription may override this for their specific requirements.
    #
    # @return [Hash]
    def subscription_opts
      { manual_ack: true, block: true }
    end
  end # class Handler
end # module BusyBunny
