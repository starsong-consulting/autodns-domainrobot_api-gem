# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents WHOIS lookup results
    # Note: WHOIS lookups use the DomainStudio API under the hood
    class Whois < BaseEntity
      def self.resource_path
        'domainstudio'
      end

      # Domain name queried
      def domain
        attributes[:domain] || attributes[:name]
      end

      # WHOIS status (e.g., "free", "registered", "reserved")
      def status
        attributes[:status] ||
          attributes.dig(:services, :whois, :data, :status)
      end

      # Raw WHOIS data if available
      def whois_data
        attributes.dig(:services, :whois, :data)
      end

      def to_s
        "Whois #{domain}: #{status}"
      end

      class << self
        # Single domain WHOIS lookup
        # @param client [Client] the API client
        # @param domain [String] domain name to lookup
        # @return [Whois] WHOIS result
        def single(client, domain)
          results = lookup(client, [domain])
          results.first
        end

        # Multiple domains WHOIS lookup
        # @param client [Client] the API client
        # @param domains [Array<String>] domain names to lookup
        # @return [Array<Whois>] array of WHOIS results
        def multi(client, domains)
          lookup(client, domains)
        end

        private

        def lookup(client, domains)
          body = {
            sources: {
              custom: {
                domains: domains,
                services: ['WHOIS']
              }
            }
          }

          response = client.post(resource_path, body: body)
          data = response[:data] || []

          data.map do |envelope|
            Whois.new({
                        domain: envelope['domain'],
                        status: envelope.dig('services', 'whois', 'data', 'status'),
                        services: envelope['services']
                      }, client: client)
          end
        end
      end
    end
  end
end
