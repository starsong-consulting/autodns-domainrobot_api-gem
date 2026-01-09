# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a DNS resource record
    class ZoneRecord < BaseEntity
      def self.resource_path
        "zone"
      end

      # Record name (subdomain or @ for apex)
      def name
        attributes[:name]
      end

      # Record type (A, AAAA, CNAME, MX, TXT, etc.)
      def type
        attributes[:type]
      end

      # Record value
      def value
        attributes[:value]
      end

      # TTL in seconds
      def ttl
        attributes[:ttl]
      end

      # Priority (for MX, SRV records)
      def pref
        attributes[:pref] || attributes[:priority]
      end
      alias priority pref

      def to_s
        "#{type} #{name} -> #{value}"
      end
    end
  end
end
