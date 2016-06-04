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
      raise NotImplementedError
    end

    private

    def run
      @queue.subscribe(subscription_opts, &method(:run_one))
    end

    def run_one(delivery_info, properties, request)
      if delivery_info.redelivered?
        handle_redelivery(
          delivery_info,
          properties.extend(PropertiesPowerup),
          request
        )
        return
      end
      handle(request)
      @channel.ack(delivery_info.delivery_tag)
    end

    def handle_redelivery(delivery_info, properties, request)
      properties.ensure_not_poison(poisoned_message_threshold)
      properties.add_retry
      @queue.publish(request, properties.to_hash)
    ensure
      # ensure_not_poison may raise an exception and we still want to get rid
      # of this message from the queue.
      @channel.ack(delivery_info.delivery_tag)
    end

    # Concrete implementations that want to change the options used for queue
    # subscription may override this for their specific requirements.
    #
    # @return [Hash]
    def subscription_opts
      { manual_ack: true, block: true }
    end

    # Concrete implementations that want to change the allowed number of
    # unsuccessful message redeliveries may override the implementation of this
    # method.
    #
    # @return [Fixnum]
    def poisoned_message_threshold
      3
    end

    # PropertiesPowerup extends Bunny::MessageProperties with redelivery logic.
    module PropertiesPowerup
      RETRY_HEADER = 'X-Retry-Count'.freeze

      def ensure_not_poison(threshold)
        raise PoisonedMessageError if retry_count < threshold
      end

      # @return [Fixnum]
      def retry_count
        headers[RETRY_HEADER].to_i
      end

      def add_retry
        headers[RETRY_HEADER] = retry_count + 1
      end
    end # module PropertiesPowerup
  end # class Handler
end # module BusyBunny
