# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a domain redirect configuration
    class Redirect < BaseEntity
      def self.resource_path
        'redirect'
      end

      # Source domain/path
      def source
        attributes[:source]
      end

      # Target URL
      def target
        attributes[:target]
      end

      # Redirect type (e.g., "HEADER301", "HEADER302", "FRAME")
      def type
        attributes[:type]
      end

      # Redirect mode
      def mode
        attributes[:mode]
      end

      # Domain associated with redirect
      def domain
        attributes[:domain]
      end

      # Title for frame redirects
      def title
        attributes[:title]
      end

      # Whether redirect is active
      def active?
        attributes[:active] == true
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
        "Redirect ##{id} (#{source} -> #{target})"
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
