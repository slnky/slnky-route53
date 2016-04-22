require 'fog/aws'

module Slnky
  module Route53
    class Client < Slnky::Client::Base
      def initialize
        @myzones = config.aws.zones.split(',').map { |e| "#{e}." }
        options = {provider: 'AWS', aws_secret_access_key: config.aws.secret, aws_access_key_id: config.aws.key}
        @dns = Fog::DNS.new(options)
        @ec2 = Fog::Compute.new(options.merge({region: config.aws.region}))
      end

      def remove_records(id)
        ip = get_ip(id)
        records = get_records(ip)
        records.each do |record|
          log.warn "instance #{id} terminated, removing record: #{record.name}"
          record.destroy if config.production?
        end
      end

      def get_name(id)
        ip = get_ip(id)
        return nil unless ip
        records = get_records(ip)
        return nil unless records.count > 0
        records.map {|e| e.name}.join(", ")
      end

      def get_ip(id)
        instance = @ec2.servers.get(id)
        instance.private_ip_address
      rescue => e
        nil
      end

      def get_zones
        zones = @dns.zones.all
        out = []
        zones.each do |zone|
          out << zone if @myzones.include?(zone.domain)
        end
        out
      end

      def get_records(ip)
        out = []
        get_all_records.each do |record|
          out << record if record.value.include?(ip)
        end
        out
      end

      def get_all_records
        out = []
        get_zones.each do |zone|
          out += get_zone_records(zone.id)
        end
        out
      end

      def get_zone_records(zoneid)
        out = []
        zone = @dns.zones.get(zoneid)
        zone.records.all!.each do |record|
          out << record if record.type == 'A'
        end
        out
      end
    end
  end
end
