# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents a poll message (notification) in AutoDNS
    class PollMessage < BaseEntity
      def self.resource_path
        "poll"
      end

      # Message ID
      def message_id
        attributes[:id] || attributes[:message_id]
      end

      # Message type
      def message_type
        attributes[:type] || attributes[:message_type]
      end

      # Message text
      def message
        attributes[:message] || attributes[:text]
      end

      # Object type this message relates to
      def object_type
        attributes[:objectType] || attributes[:object_type]
      end

      # Object ID this message relates to
      def related_object_id
        attributes[:object] || attributes[:objectId]
      end

      # Job related to this message
      def job
        association(:job, "Job")
      end

      # Created timestamp
      def created_at
        parse_datetime(attributes[:created] || attributes[:stid])
      end

      def to_s
        "PollMessage ##{id} (#{message_type})"
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
