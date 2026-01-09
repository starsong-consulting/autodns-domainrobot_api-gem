# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a contact (handle) in AutoDNS
    class Contact < BaseEntity
      def self.resource_path
        "contact"
      end

      # Full name (combined first + last)
      def full_name
        [fname, lname].compact.reject(&:empty?).join(" ")
      end

      # First name
      def fname
        attributes[:fname]
      end

      # Last name
      def lname
        attributes[:lname]
      end

      # Organization name
      def organization
        attributes[:organization]
      end

      # Contact type (e.g., "PERSON", "ORG")
      def type
        attributes[:type]
      end

      # Address lines (array)
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

      # Country code (ISO 3166-1 alpha-2)
      def country
        attributes[:country]
      end

      # Phone number
      def phone
        attributes[:phone]
      end

      # Fax number
      def fax
        attributes[:fax]
      end

      # Email address
      def email
        attributes[:email]
      end

      # SIP address
      def sip
        attributes[:sip]
      end

      # Verification status
      def verification
        attributes[:verification]
      end

      # Privacy protection
      def protection
        attributes[:protection]
      end

      def to_s
        name_part = full_name.presence || organization || id.to_s
        "Contact ##{id} (#{name_part})"
      end
    end
  end
end
