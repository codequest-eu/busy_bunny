module BusyBunny
  # PoisonedMessageError occurs when a message has been unsuccessfully delivered
  # more times than the Publisher allows
  class PoisonedMessageError < ::StandardError; end
end # module BusyBunny
