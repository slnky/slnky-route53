module Slnky
  module Route53
    class Mock < Slnky::Route53::Client
      # unless there's something special you need to do in the initializer
      # use the one provided by the actual client object
      # def initialize
      #
      # end

      def remove_records(id)
        if id == 'i-12345678'
          "#{id} not found"
        else
          "remove #{id}"
        end
      end
    end
  end
end
