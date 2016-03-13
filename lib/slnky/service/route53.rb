require 'slnky'
require 'aws-sdk'

module Slnky
  module Service
    class Route53 < Base
      subscribe 'aws.ec2.terminated', :handle_terminated
      subscribe 'aws.*', :handle_aws

      def handle_aws(name, data)
        puts "aws: #{name} #{data.inspect}"
      end

      def handle_terminated(name, data)
        id = data.detail['instance-id']
        remove_records(id)
      end

      def remove_records(id)
        log :warn, "removing records for #{id}"
        Aws.config.update({region: config.aws.region, credentials: Aws::Credentials.new(config.aws.key, config.aws.secret)})
        ec2 = Aws::EC2::Resource.new

        begin
          instance = ec2.instances(instance_ids: [id]).first
        rescue => e
          log :error, "instance not found: #{e.message}"
          instance = nil
        end

        if instance
          ip = instance.private_ip_address
          log :info, "found instance #{id}: #{ip}"
          dns = Aws::Route53::Resource.new
          puts dns.inspect
        end

        true
      end
    end
  end
end
