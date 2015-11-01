require 'bundler/setup'
Bundler.setup

require 'busy_bunny'

module BusyBunny
  # MockSubscriber is a mock implementation of BusyBunny::Subscriber.
  class MockSubscriber < Subscriber
    def initialize(channel, queue, thread)
      @channel = channel
      @queue   = queue
      @thread  = thread
    end
  end # class MockSubscriber

  # MockPublisher is a mock implementation of BusyBunny::Subscriber.
  class MockPublisher < Publisher
    def initialize(channel, queue)
      @channel = channel
      @queue = queue
    end
  end # class MockPublisher

  # MockSubscriberPool is a mock implementation of BusyBunny::SubscriberPool.
  class MockSubscriberPool < SubscriberPool
    def initialize(conns, subscribers)
      @conns = conns
      @subscribers = subscribers
    end
  end # class MockSubscriberPool
end # module BusyBunny
