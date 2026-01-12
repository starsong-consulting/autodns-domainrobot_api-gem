# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a domain registration in AutoDNS
    class Domain < BaseEntity
      def self.resource_path
        'domain'
      end

      # Owner contact (registrant)
      def ownerc
        association(:ownerc, 'Contact')
      end

      # Admin contact
      def adminc
        association(:adminc, 'Contact')
      end

      # Technical contact
      def techc
        association(:techc, 'Contact')
      end

      # Zone contact (billing)
      def zonec
        association(:zonec, 'Contact')
      end

      # Nameservers as NameServer entities
      def nameservers
        @nameservers ||= begin
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
        when true, 'true', 'TRUE', '1', 1, 'ACTIVE'
          true
        when false, 'false', 'FALSE', '0', 0, 'INACTIVE'
          false
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

      # --- Advanced Domain Operations ---

      # Renew the domain
      # @return [Job] the async job
      def renew!
        response = client.put("#{self.class.resource_path}/#{name}/_renew", body: to_h)
        Job.new(response[:data]&.first || {}, client: client)
      end

      # Create AuthInfo1 (transfer key)
      # @return [Domain] updated domain with authinfo
      def create_authinfo1!
        response = client.post("#{self.class.resource_path}/#{name}/_authinfo1")
        Domain.new(response[:data]&.first || {}, client: client)
      end

      # Delete AuthInfo1
      def delete_authinfo1!
        client.delete("#{self.class.resource_path}/#{name}/_authinfo1")
        true
      end

      # Create AuthInfo2
      # @return [Domain] updated domain with authinfo
      def create_authinfo2!
        response = client.post("#{self.class.resource_path}/#{name}/_authinfo2")
        Domain.new(response[:data]&.first || {}, client: client)
      end

      # Send AuthInfo to owner contact via email
      def send_authinfo_to_owner!
        client.put("#{self.class.resource_path}/#{name}/_sendAuthinfoToOwnerc")
        true
      end

      # Add domain to Domain Safe (transfer lock)
      def add_to_domain_safe!
        client.put("#{self.class.resource_path}/#{name}/_domainSafe")
        true
      end

      # Remove domain from Domain Safe
      def remove_from_domain_safe!
        client.delete("#{self.class.resource_path}/#{name}/_domainSafe")
        true
      end

      # Trigger DNSSEC key rollover (AutoDNSSec must be enabled)
      def dnssec_key_rollover!
        client.put("#{self.class.resource_path}/#{name}/_autoDnssecKeyRollover")
        true
      end

      # Update domain comment
      # @param comment [String] the new comment
      def update_comment!(comment)
        client.put("#{self.class.resource_path}/#{name}/_comment", body: { comment: comment })
        true
      end

      # Change owner (registrant) - creates async job
      # @param new_owner [Contact, Hash] the new owner contact
      # @return [Job] the async job
      def change_owner!(new_owner)
        owner_data = new_owner.is_a?(Contact) ? new_owner.to_h : new_owner
        response = client.put("#{self.class.resource_path}/#{name}/_ownerChange", body: { ownerc: owner_data })
        Job.new(response[:data]&.first || {}, client: client)
      end

      # Update registry status
      # @param status [String] the new status
      # @return [Job] the async job
      def update_status!(status)
        response = client.put("#{self.class.resource_path}/#{name}/_statusUpdate", body: { registryStatus: status })
        Job.new(response[:data]&.first || {}, client: client)
      end

      # Restore an expired/deleted domain
      # @return [Job] the async job
      def restore!
        response = client.put("#{self.class.resource_path}/#{name}/_restore", body: to_h)
        Job.new(response[:data]&.first || {}, client: client)
      end

      # --- Class methods for domain operations ---

      class << self
        # Transfer a domain from another registrar
        # @param client [Client] the API client
        # @param domain_data [Hash] domain data including name and authinfo
        # @return [Job] the async job
        def transfer(client, domain_data)
          response = client.post("#{resource_path}/_transfer", body: domain_data)
          Job.new(response[:data]&.first || {}, client: client)
        end

        # Buy a premium domain
        # @param client [Client] the API client
        # @param domain_data [Hash] domain data
        # @return [Job] the async job
        def buy(client, domain_data)
          response = client.post("#{resource_path}/_buy", body: domain_data)
          Job.new(response[:data]&.first || {}, client: client)
        end

        # Import an existing domain
        # @param client [Client] the API client
        # @param domain_data [Hash] domain data
        # @return [Job] the async job
        def import(client, domain_data)
          response = client.post("#{resource_path}/_import", body: domain_data)
          Job.new(response[:data]&.first || {}, client: client)
        end

        # Trade (change owner with registry)
        # @param client [Client] the API client
        # @param domain_data [Hash] domain data with new owner
        # @return [Job] the async job
        def trade(client, domain_data)
          response = client.post("#{resource_path}/_trade", body: domain_data)
          Job.new(response[:data]&.first || {}, client: client)
        end

        # List domains pending auto-delete
        # @param client [Client] the API client
        # @param query [Hash] optional query filters
        # @return [Array<Domain>] list of domains
        def autodelete_list(client, query = nil)
          response = client.post("#{resource_path}/autodelete/_search", body: query)
          (response[:data] || []).map { |d| new(d, client: client) }
        end

        # List restorable domains
        # @param client [Client] the API client
        # @param query [Hash] optional query filters
        # @return [Array<Domain>] list of restorable domains
        def restore_list(client, query = nil)
          response = client.post("#{resource_path}/restore/_search", body: query)
          (response[:data] || []).map { |d| new(d, client: client) }
        end
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
