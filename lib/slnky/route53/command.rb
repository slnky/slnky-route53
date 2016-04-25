module Slnky
  module Route53
    class Command < Slnky::Command::Base
      attr_writer :client
      def client
        @client ||= Slnky::Route53::Client.new
      end

      # # use docopt to define arguments and options
      # command :echo, 'respond with the given arguments', <<-USAGE.strip_heredoc
      #   Usage: echo [options] ARGS...
      #
      #   -h --help           print help.
      #   -x --times=TIMES    print x times [default: 1].
      # USAGE
      #
      # # handler methods receive request, response, and options objects
      # def handle_echo(request, response, opts)
      #   # parameters (non-option arguments) are available as accessors
      #   args = opts.args
      #   # as are the options themselves (by their 'long' name)
      #   1.upto(opts.times.to_i) do |i|
      #     # just use the log object to respond, it will automatically send it
      #     # to the correct channel.
      #     log.info args.join(" ")
      #   end
      # end

      command :lookup, 'get name for given ID', <<-USAGE.strip_heredoc
        Usage: lookup [options] ID

        -h --help           print help.
      USAGE
      def handle_lookup(request, response, opts)
        id = opts.id
        list = client.get_name(id)
        if list
          log.info "instance #{id} name is: #{list.join(', ')}"
        else
          log.info "no names found for instance #{id}"
        end
      end
    end
  end
end
