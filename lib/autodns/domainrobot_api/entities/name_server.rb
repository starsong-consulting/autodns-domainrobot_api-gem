# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a nameserver configuration
    class NameServer < BaseEntity
      def self.resource_path
        'nameserver'
      end

      # Nameserver hostname
      def name
        attributes[:name]
      end

      # IPv4 addresses (glue records)
      def ips_v4
        attributes[:ipsV4] || attributes[:ips_v4] || []
      end
      alias ipv4 ips_v4

      # IPv6 addresses (glue records)
      def ips_v6
        attributes[:ipsV6] || attributes[:ips_v6] || []
      end
      alias ipv6 ips_v6

      def to_s
        name.to_s
      end
    end
  end
end
