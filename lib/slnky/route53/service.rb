module Slnky
  module Route53
    class Service < Slnky::Service::Base
      attr_writer :client
      def client
        @client ||= Slnky::Route53::Client.new
      end

      subscribe 'aws.ec2.terminated', :handle_terminated

      def handle_terminated(name, data)
        id = data.detail['instance-id']
        client.remove_records(id)
      end

      subscribe 'slnky.service.test', :handle_test
      # you can also subscribe to heirarchies, this gets
      # all events under something.happened
      # subscribe 'something.happened.*', :other_handler

      def handle_test(name, data)
        name == 'slnky.service.test' && data.hello == 'world!'
      end
    end
  end
end
