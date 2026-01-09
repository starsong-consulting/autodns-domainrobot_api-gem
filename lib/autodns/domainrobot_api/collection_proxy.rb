# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Provides a chainable query interface for API resources
    # Follows similar patterns to ActiveRecord for familiar usage
    #
    # @example
    #   client.domains.where(name: "*.com").limit(10).all
    #   client.domains.find("example.com")
    #   client.contacts.create(fname: "John", lname: "Doe")
    #
    class CollectionProxy
      include Enumerable

      # Rate limit: AutoDNS allows 3 requests/second
      RATE_LIMIT_DELAY = 0.35

      def initialize(client, entity_name)
        @client = client
        @entity_name = entity_name
        @entity_class = ENTITIES[entity_name]
        @filters = {}
        @limit = nil
        @offset = 0
        @keys = nil
        @cached_results = nil
      end

      # Chainable query methods

      def where(conditions = {})
        dup.tap { |proxy| proxy.instance_variable_set(:@filters, @filters.merge(conditions)) }
      end

      def limit(count)
        dup.tap { |proxy| proxy.instance_variable_set(:@limit, count) }
      end

      def offset(count)
        dup.tap { |proxy| proxy.instance_variable_set(:@offset, count) }
      end

      def keys(*field_names)
        dup.tap { |proxy| proxy.instance_variable_set(:@keys, field_names.flatten) }
      end

      # Terminal methods

      def all
        @cached_results ||= fetch_all
      end

      def each(&block)
        all.each(&block)
      end

      def first
        limit(1).all.first
      end

      def find(id)
        path = "#{resource_path}/#{id}"
        response = @client.get(path)
        data = response[:data]&.first
        return nil unless data

        @entity_class.new(data, client: @client)
      end

      def find_by(conditions)
        where(conditions).first
      end

      def create(attributes)
        data = attributes.is_a?(BaseEntity) ? attributes.to_h : attributes
        response = @client.post(resource_path, body: data)
        result_data = response[:data]&.first || response[:object]
        return nil unless result_data

        @entity_class.new(result_data, client: @client)
      end

      def update(id, attributes)
        data = attributes.is_a?(BaseEntity) ? attributes.to_h : attributes
        path = "#{resource_path}/#{id}"
        response = @client.put(path, body: data)
        result_data = response[:data]&.first || response[:object]
        return nil unless result_data

        @entity_class.new(result_data, client: @client)
      end

      def delete(id)
        path = "#{resource_path}/#{id}"
        @client.delete(path)
        true
      rescue Error
        false
      end

      def count
        response = search(limit: 1, offset: 0)
        response[:object]&.dig("summary") || response[:data]&.length || 0
      end

      private

      def resource_path
        @entity_class.resource_path
      end

      def fetch_all
        if @limit
          # Single request with limit
          response = search(limit: @limit, offset: @offset)
          wrap_results(response[:data] || [])
        else
          # Paginated fetch all
          fetch_all_paginated
        end
      end

      def fetch_all_paginated(batch_size: 100)
        all_results = []
        current_offset = @offset

        loop do
          response = search(limit: batch_size, offset: current_offset)
          data = response[:data] || []
          break if data.empty?

          all_results.concat(data)
          current_offset += batch_size

          # Rate limiting
          sleep(RATE_LIMIT_DELAY)

          break if data.length < batch_size
        end

        wrap_results(all_results)
      end

      def search(limit:, offset:)
        body = {
          view: {
            limit: limit,
            offset: offset
          }
        }

        body[:filters] = build_filters if @filters.any?
        body[:keys] = @keys if @keys

        @client.post("#{resource_path}/_search", body: body)
      end

      def build_filters
        @filters.map do |key, value|
          {
            key: key.to_s,
            value: value,
            operator: value.to_s.include?("*") ? "LIKE" : "EQUAL"
          }
        end
      end

      def wrap_results(data)
        data.map { |item| @entity_class.new(item, client: @client) }
      end
    end
  end
end
