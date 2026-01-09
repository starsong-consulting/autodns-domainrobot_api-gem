# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a domain registration in AutoDNS
    class Domain < BaseEntity
      def self.resource_path
        "domain"
      end

      # Owner contact (registrant)
      def ownerc
        association(:ownerc, "Contact")
      end

      # Admin contact
      def adminc
        association(:adminc, "Contact")
      end

      # Technical contact
      def techc
        association(:techc, "Contact")
      end

      # Zone contact (billing)
      def zonec
        association(:zonec, "Contact")
      end

      # Nameservers as NameServer entities
      def nameservers
        @_nameservers ||= begin
          ns_data = attributes[:nameServers] || attributes[:name_servers] || []
          ns_data.map do |ns|
            ns.is_a?(NameServer) ? ns : NameServer.new(ns, client: client)
          end
        end
      end

      # Convenience method for nameserver hostnames
      def nameserver_names
        nameservers.map { |ns| ns.name || ns.attributes[:name] }.compact
      end

      # IDN (internationalized domain name) version
      def idn
        attributes[:idn]
      end

      # Domain expiry/payable date
      def expire_date
        parse_date(attributes[:payable] || attributes[:expire])
      end

      # Auto-renew status
      def auto_renew?
        case attributes[:autoRenewStatus] || attributes[:auto_renew_status]
        when true, "true", "TRUE", "1", 1, "ACTIVE"
          true
        when false, "false", "FALSE", "0", 0, "INACTIVE"
          false
        else
          nil
        end
      end

      # Registry status
      def registry_status
        attributes[:registryStatus] || attributes[:registry_status]
      end

      # Registrar status
      def registrar_status
        attributes[:registrarStatus] || attributes[:registrar_status]
      end

      # Auth info (transfer key)
      def auth_info
        attributes[:authinfo] || attributes[:auth_info]
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
        "Domain #{name}"
      end

      private

      def parse_date(value)
        return nil if value.nil? || value.to_s.empty?

        Date.parse(value.to_s)
      rescue ArgumentError
        nil
      end

      def parse_datetime(value)
        return nil if value.nil? || value.to_s.empty?

        DateTime.parse(value.to_s)
      rescue ArgumentError
        nil
      end
    end
  end
end
