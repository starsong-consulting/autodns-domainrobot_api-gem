# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # DomainStudio provides domain name suggestions and availability checks
    # Uses the /domainstudio API endpoint
    class DomainStudio < BaseEntity
      def self.resource_path
        'domainstudio'
      end

      # Domain name
      def domain
        attributes[:domain]
      end

      # IDN (internationalized) version
      def idn
        attributes[:idn]
      end

      # TLD
      def tld
        attributes[:tld]
      end

      # Sub-TLD (e.g., co.uk)
      def sub_tld
        attributes[:subTld] || attributes[:sub_tld]
      end

      # Source of the suggestion
      def source
        attributes[:source]
      end

      # Services data (WHOIS, price, etc.)
      def services
        attributes[:services]
      end

      # Whether user already owns this domain
      def portfolio?
        attributes[:portfolio] == true
      end

      # Whether domain is for pre-registration only
      def prereg?
        attributes[:isPrereg] == true
      end

      # WHOIS status from services
      def whois_status
        services&.dig(:whoisStatus) || services&.dig(:whois_status)
      end

      # Domain availability
      def available?
        %w[FREE AVAILABLE].include?(whois_status)
      end

      # Price info from services
      def price
        services&.dig(:priceData) || services&.dig(:price_data)
      end

      # Estimated price
      def estimated_price
        services&.dig(:estimateData) || services&.dig(:estimate_data)
      end

      def to_s
        status = available? ? 'available' : 'taken'
        "DomainStudio #{domain} (#{status})"
      end

      # --- Class methods for DomainStudio operations ---

      class << self
        # Search for domain suggestions
        # @param client [Client] the API client
        # @param search_token [String] keyword or domain name to search
        # @param options [Hash] optional search options
        # @option options [String] :currency price currency (e.g., "USD", "EUR")
        # @option options [Boolean] :only_available filter to available domains only
        # @option options [Boolean] :check_portfolio check if user owns domains
        # @option options [Boolean] :force_dns_check use DNS for availability check
        # @option options [Boolean] :ignore_premium exclude premium domains
        # @option options [Boolean] :ignore_market exclude market domains
        # @option options [Integer] :whois_timeout WHOIS timeout in seconds
        # @option options [Hash] :sources source configuration
        # @return [Array<DomainStudio>] array of domain suggestions
        def search(client, search_token, options = {})
          body = build_search_request(search_token, options)
          response = client.post(resource_path, body: body)
          (response[:data] || []).map { |d| new(d, client: client) }
        end

        private

        def build_search_request(search_token, options)
          request = { searchToken: search_token }

          # Map Ruby-style options to API camelCase
          option_mapping = {
            currency: :currency,
            only_available: :onlyAvailable,
            check_portfolio: :checkPortfolio,
            force_dns_check: :forceDnsCheck,
            ignore_premium: :ignorePremium,
            ignore_market: :ignoreMarket,
            whois_timeout: :whoisTimeout,
            sources: :sources
          }

          option_mapping.each do |ruby_key, api_key|
            request[api_key] = options[ruby_key] if options.key?(ruby_key)
          end

          request
        end
      end
    end
  end
end
