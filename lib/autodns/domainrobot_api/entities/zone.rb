# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a DNS zone in AutoDNS
    class Zone < BaseEntity
      def self.resource_path
        'zone'
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
        @resource_records ||= begin
          records = attributes[:resourceRecords] || attributes[:resource_records] || []
          records.map do |rec|
            rec.is_a?(ZoneRecord) ? rec : ZoneRecord.new(rec, client: client)
          end
        end
      end
      alias records resource_records

      # Nameservers for this zone
      def nameservers
        @nameservers ||= begin
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

      # --- Zone Operations ---

      # Stream records - add and/or remove records incrementally
      # @param adds [Array<Hash>] records to add
      # @param removes [Array<Hash>] records to remove
      # @return [Zone] updated zone
      def stream!(adds: [], removes: [])
        body = { adds: adds, rems: removes }
        response = client.post("#{self.class.resource_path}/#{origin}/_stream", body: body)
        Zone.new(response[:data]&.first || {}, client: client)
      end

      # Add records to the zone
      # @param records [Array<Hash>] records to add
      # @return [Zone] updated zone
      def add_records!(records)
        stream!(adds: records)
      end

      # Remove records from the zone
      # @param records [Array<Hash>] records to remove
      # @return [Zone] updated zone
      def remove_records!(records)
        stream!(removes: records)
      end

      # Patch zone (partial update)
      # @param changes [Hash] partial zone data to update
      # @return [Zone] updated zone
      def patch!(changes)
        ns = primary_nameserver || system_nameserver
        response = client.patch("#{self.class.resource_path}/#{origin}/#{ns}",
                                body: changes.merge(origin: origin, virtualNameServer: ns))
        Zone.new(response[:data]&.first || {}, client: client)
      end

      # --- Class methods for zone operations ---

      class << self
        # Import an existing zone
        # @param client [Client] the API client
        # @param origin [String] zone origin (domain name)
        # @param nameserver [String] primary nameserver
        # @param zone_data [Hash] optional additional zone data
        # @return [Zone] imported zone
        def import(client, origin, nameserver, zone_data = {})
          body = zone_data.merge(origin: origin, virtualNameServer: nameserver)
          response = client.post("#{resource_path}/#{origin}/#{nameserver}/_import", body: body)
          new(response[:data]&.first || {}, client: client)
        end
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
