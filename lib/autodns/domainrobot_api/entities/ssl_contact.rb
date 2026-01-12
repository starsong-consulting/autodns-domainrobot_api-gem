# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents an SSL certificate contact (separate from domain contacts)
    class SslContact < BaseEntity
      def self.resource_path
        'sslcontact'
      end

      # First name
      def fname
        attributes[:fname]
      end

      # Last name
      def lname
        attributes[:lname]
      end

      # Full name
      def full_name
        [fname, lname].compact.reject(&:empty?).join(' ')
      end

      # Organization
      def organization
        attributes[:organization]
      end

      # Title/position
      def title
        attributes[:title]
      end

      # Email
      def email
        attributes[:email]
      end

      # Phone
      def phone
        attributes[:phone]
      end

      # Fax
      def fax
        attributes[:fax]
      end

      # Address lines
      def address
        attributes[:address] || []
      end

      # City
      def city
        attributes[:city]
      end

      # State/Province
      def state
        attributes[:state]
      end

      # Postal code
      def postal_code
        attributes[:pcode] || attributes[:postal_code]
      end

      # Country code
      def country
        attributes[:country]
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
        name_part = full_name.presence || organization || id.to_s
        "SslContact ##{id} (#{name_part})"
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
