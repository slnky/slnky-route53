require 'aws-sdk'

module Slnky
  module Route53
    class Client < Slnky::Client::Base
      def initialize
        @myzones = config.aws.zones.split(',').map { |e| "#{e}." }
        Aws.config.update({region: config.aws.region, credentials: Aws::Credentials.new(config.aws.key, config.aws.secret)})
        @dns = Aws::Route53::Client.new
        @ec2 = Aws::EC2::Resource.new
      end

      def remove_records(id)
        log.info "removing records for #{id}"

        ip = get_ip(id)
        unless ip
          log.info "could not get records for #{id} #{ip}"
          return
        end

        ip = instance.private_ip_address
        log.info "found instance #{id}: #{ip}"
        zones = get_zones
        zones.each do |zone|
          records = get_records(zone.id, ip)
          records.each do |record|
            remove_record(id, zone.id, record)
          end
        end

        true
      end

      def get_ip(id)
        instance = @ec2.instances(instance_ids: [id]).first
        instance.private_ip_address
      rescue => e
        log.error "could not get ip for #{id}: #{e.message}"
        nil
      end

      def get_zones
        @dns.list_hosted_zones.hosted_zones.select { |z| @myzones.include?(z.name) }
      end

      def get_records(zoneid, ip)
        puts "get_records: #{zoneid} #{ip}"
        out = []
        response = @dns.list_resource_record_sets(hosted_zone_id: zoneid)
        puts "response: #{response.next_record_name}"
        records = response.resource_record_sets
        puts "count: #{records.count}"
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

      def get_zone_records(zoneid, start="")
        @dns.list_resource_record_sets(hosted_zone_id: zoneid, start_record_type:'A') do |page|
          puts page.inspect
        end
      end

      def remove_record(id, zoneid, record)
        log.warn "termintated #{id}: removing record: #{record.name}"
        if config.development?
          log.info "not removing, in development environment"
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
