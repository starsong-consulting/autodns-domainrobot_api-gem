# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a DNS zone in AutoDNS
    class Zone < BaseEntity
      def self.resource_path
        "zone"
      end

      # Zone origin (domain name)
      def origin
        attributes[:origin] || attributes[:name]
      end

      # Primary nameserver
      def primary_nameserver
        attributes[:virtualNameServer] || attributes[:primary_nameserver]
      end

      # SOA email
      def soa_email
        attributes[:soaEmail] || attributes[:soa_email]
      end

      # Zone records
      def resource_records
        @_records ||= begin
          records = attributes[:resourceRecords] || attributes[:resource_records] || []
          records.map do |rec|
            rec.is_a?(ZoneRecord) ? rec : ZoneRecord.new(rec, client: client)
          end
        end
      end
      alias records resource_records

      # Nameservers for this zone
      def nameservers
        @_nameservers ||= begin
          ns_data = attributes[:nameServers] || attributes[:name_servers] || []
          ns_data.map do |ns|
            ns.is_a?(NameServer) ? ns : NameServer.new(ns, client: client)
          end
        end
      end

      # Zone system nameserver
      def system_nameserver
        attributes[:systemNameServer] || attributes[:system_name_server]
      end

      # Main record (A/AAAA for zone apex)
      def main
        attributes[:main]
      end

      # WWW subdomain configuration
      def www_include
        attributes[:wwwInclude] || attributes[:www_include]
      end

      # DNSSEC enabled
      def dnssec?
        attributes[:dnssec] == true
      end

      # Created timestamp
      def created_at
        parse_datetime(attributes[:created])
      end

      # Updated timestamp
      def updated_at
        parse_datetime(attributes[:updated])
      end

      def to_s
        "Zone #{origin}"
      end

      private

      def parse_datetime(value)
        return nil if value.nil? || value.to_s.empty?

        DateTime.parse(value.to_s)
      rescue ArgumentError
        nil
      end
    end
  end
end
