require "lita"

module Lita
  module Adapters
    class IRC < Adapter
    end

    Lita.register_adapter(:irc, IRC)
  end
end
