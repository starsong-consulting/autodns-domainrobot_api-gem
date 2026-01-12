# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a domain cancelation request
    class DomainCancelation < BaseEntity
      def self.resource_path
        'domain/cancelation'
      end

      # Domain name being cancelled
      def domain
        attributes[:domain]
      end

      # Cancelation type (DELETE, TRANSIT, etc.)
      def type
        attributes[:type]
      end

      # Execution date
      def exec_date
        parse_date(attributes[:execdate] || attributes[:exec_date])
      end

      # Registry status
      def registry_status
        attributes[:registryStatus] || attributes[:registry_status]
      end

      # Gaining registrar (for transfers)
      def gaining_registrar
        attributes[:gainingRegistrar] || attributes[:gaining_registrar]
      end

      # Disconnect from zone
      def disconnect?
        attributes[:disconnect] == true
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
        "DomainCancelation #{domain} (#{type})"
      end

      # --- Instance methods ---

      # Update this cancelation
      def save!
        raise ArgumentError, 'Domain name required' unless domain

        response = client.put("domain/#{domain}/cancelation", body: to_h)
        DomainCancelation.new(response[:data]&.first || {}, client: client)
      end

      # Delete/cancel this cancelation request
      def delete!
        raise ArgumentError, 'Domain name required' unless domain

        client.delete("domain/#{domain}/cancelation")
        true
      end

      # --- Class methods ---

      class << self
        # Create a new domain cancelation
        # @param client [Client] the API client
        # @param domain_name [String] domain name to cancel
        # @param options [Hash] cancelation options
        # @option options [String] :type cancelation type (DELETE, TRANSIT)
        # @option options [Date, String] :exec_date execution date
        # @option options [Boolean] :disconnect disconnect from zone
        # @return [DomainCancelation] the created cancelation
        def create(client, domain_name, options = {})
          body = options.merge(domain: domain_name)
          body[:execdate] = body.delete(:exec_date) if body[:exec_date]
          response = client.post("domain/#{domain_name}/cancelation", body: body)
          new(response[:data]&.first || {}, client: client)
        end

        # Get cancelation info for a domain
        # @param client [Client] the API client
        # @param domain_name [String] domain name
        # @return [DomainCancelation] the cancelation
        def info(client, domain_name)
          response = client.get("domain/#{domain_name}/cancelation")
          new(response[:data]&.first || {}, client: client)
        end

        # List all domain cancelations
        # @param client [Client] the API client
        # @param query [Hash] optional query filters
        # @return [Array<DomainCancelation>] list of cancelations
        def list(client, query = nil)
          response = client.post("#{resource_path}/_search", body: query)
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
