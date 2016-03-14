require 'slnky'
require 'aws-sdk'

module Slnky
  module Service
    class Route53 < Base
      def initialize(url, options={})
        super(url, options)
        @myzones = config.aws.zones.split(',').map{|e| "#{e}."}
        Aws.config.update({region: config.aws.region, credentials: Aws::Credentials.new(config.aws.key, config.aws.secret)})
        @dns = Aws::Route53::Client.new
        @ec2 = Aws::EC2::Resource.new
      end

      subscribe 'aws.ec2.terminated', :handle_terminated

      def handle_terminated(name, data)
        id = data.detail['instance-id']
        remove_records(id)
      end

      def remove_records(id)
        log :warn, "removing records for #{id}"

        begin
          instance = @ec2.instances(instance_ids: [id]).first
        rescue => e
          log :error, "instance not found: #{e.message}"
          instance = nil
        end

        if instance
          ip = instance.private_ip_address
          log :info, "found instance #{id}: #{ip}"
          zones = get_zones
          zones.each do |zone|
            records = get_records(zone.id, ip)
            records.each do |record|
              remove_record(zone.id, record)
            end
          end
        end

        true
      end

      def get_zones
        @dns.list_hosted_zones.hosted_zones.select {|z| @myzones.include?(z.name)}
      end

      def get_records(zoneid, ip)
        out = []
        records = @dns.list_resource_record_sets(hosted_zone_id: zoneid).resource_record_sets
        records.each do |record|
          next unless record.type == 'A'
          record.resource_records.each do |r|
            if r.value == ip
              out << record
            end
          end
        end
        out
      end

      def remove_record(zoneid, record)
        log :warn, "removing record: #{record.name}"
        if development?
          log :info, "not removing, in development environment"
          return
        end
        @dns.change_resource_record_sets({
            hosted_zone_id: zoneid,
            change_batch: {
                comment: "remove record #{record.name}",
                changes: [
                    {
                        action: 'DELETE',
                        resource_record_set: record
                    }
                ]
            }
        })
      end
    end
  end
end
