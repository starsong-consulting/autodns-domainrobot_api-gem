# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a domain transfer-out request
    class TransferOut < BaseEntity
      def self.resource_path
        'transferout'
      end

      # Domain being transferred
      def domain
        attributes[:domain]
      end

      # Transfer status
      def status
        attributes[:status]
      end

      # Gaining registrar
      def gaining_registrar
        attributes[:gainingRegistrar] || attributes[:gaining_registrar]
      end

      # Losing registrar (us)
      def losing_registrar
        attributes[:losingRegistrar] || attributes[:losing_registrar]
      end

      # Request date
      def request_date
        parse_datetime(attributes[:requestDate] || attributes[:request_date])
      end

      # ACK deadline
      def ack_deadline
        parse_datetime(attributes[:ackDeadline] || attributes[:ack_deadline])
      end

      # Created timestamp
      def created_at
        parse_datetime(attributes[:created])
      end

      # Updated timestamp
      def updated_at
        parse_datetime(attributes[:updated])
      end

      # Answer a transfer request (approve or deny)
      # @param answer [String] "ACK" to approve, "NACK" to deny
      def answer(response)
        return false unless client

        client.post("#{self.class.resource_path}/#{domain}/_answer", body: { answer: response })
        true
      rescue Error
        false
      end

      # Approve the transfer
      def approve!
        answer('ACK')
      end

      # Deny the transfer
      def deny!
        answer('NACK')
      end

      def to_s
        "TransferOut #{domain} (#{status})"
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
