require 'slnky'

module Slnky
  module Service
    class Route53 < Base
      def run
        subscribe 'event.name' do |message|
          name = message.name
          data = message.payload
          # do something
        end
      end
    end
  end
end
