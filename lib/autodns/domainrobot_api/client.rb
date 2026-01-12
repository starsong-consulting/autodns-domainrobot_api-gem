# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Main client class for the AutoDNS Domain Robot API
    # Provides dynamic collection access via method_missing
    #
    # @example
    #   client = Autodns::DomainrobotApi::Client.new(
    #     url: "https://api.autodns.com/v1",
    #     username: "user",
    #     password: "pass",
    #     context: "4"
    #   )
    #   client.domains.all
    #   client.domains.find("example.com")
    #   client.contacts.find(123)
    #
    class Client
      attr_reader :connection

      def initialize(username:, password:, url: Connection::BASE_URL, context: '4', debug: false)
        @connection = Connection.new(
          url: url,
          username: username,
          password: password,
          context: context,
          debug: debug
        )
        @collections = {}
      end

      # Delegate HTTP methods to connection
      %i[get post put patch delete].each do |method|
        define_method(method) do |path, body: nil, params: {}|
          @connection.public_send(method, path, body: body, params: params)
        end
      end

      def test_connection
        @connection.test_connection
      end

      # WHOIS lookup for a single domain
      # @param domain [String] domain name to lookup
      # @return [Whois] WHOIS result
      def whois(domain)
        Whois.single(self, domain)
      end

      # WHOIS lookup for multiple domains
      # @param domains [Array<String>] domain names to lookup
      # @return [Array<Whois>] array of WHOIS results
      def whois_multi(domains)
        Whois.multi(self, domains)
      end

      # DomainStudio search for domain suggestions
      # @param search_token [String] keyword or domain name to search
      # @param options [Hash] optional search options
      # @return [Array<DomainStudio>] array of domain suggestions
      def domain_studio(search_token, options = {})
        DomainStudio.search(self, search_token, options)
      end

      # Dynamic collection access
      # Allows client.domains, client.contacts, client.zones, etc.
      def method_missing(method, *args, &block)
        entity_name = method.to_s.singularize.camelize
        return super unless entity_exists?(entity_name)

        @collections[method] ||= CollectionProxy.new(self, entity_name)
      end

      def respond_to_missing?(method, include_private = false)
        entity_name = method.to_s.singularize.camelize
        entity_exists?(entity_name) || super
      end

      private

      def entity_exists?(name)
        ENTITIES.key?(name)
      end
    end
  end
end
