# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Represents an async job in AutoDNS
    class Job < BaseEntity
      def self.resource_path
        'job'
      end

      # Job status (e.g., RUNNING, SUCCESS, FAILED)
      def status
        attributes[:status]
      end

      # Job type/action
      def action
        attributes[:action]
      end

      # Job sub-status
      def sub_status
        attributes[:subStatus] || attributes[:sub_status]
      end

      # Object type this job relates to
      def object_type
        attributes[:type] || attributes[:object_type]
      end

      # Object ID this job relates to
      def related_object_id
        attributes[:object] || attributes[:objectId]
      end

      # Execution date
      def execution_date
        parse_datetime(attributes[:execDate] || attributes[:execution_date])
      end

      # Created timestamp
      def created_at
        parse_datetime(attributes[:created])
      end

      # Updated timestamp
      def updated_at
        parse_datetime(attributes[:updated])
      end

      def completed?
        %w[SUCCESS FAILED CANCELLED].include?(status)
      end

      def successful?
        status == 'SUCCESS'
      end

      def failed?
        status == 'FAILED'
      end

      def running?
        status == 'RUNNING'
      end

      def to_s
        "Job ##{id} (#{status})"
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
