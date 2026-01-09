# frozen_string_literal: true

module Autodns
  module DomainrobotApi
    # Base class for all AutoDNS API entities
    # Provides attribute handling, serialization, and association support
    class BaseEntity
      attr_reader :client, :attributes

      # Define the API resource path for this entity
      # Override in subclasses as needed
      def self.resource_path
        ActiveSupport::Inflector.underscore(name.split("::").last)
      end

      def initialize(data = {}, client: nil)
        @client = client

        data = {} if data.nil?
        raise ArgumentError, "BaseEntity must be initialized with a Hash, got: #{data.class}" unless data.is_a?(Hash)

        @attributes = data.transform_keys(&:to_sym)
                          .each_with_object({}) do |(k, v), acc|
                            acc[k] = process_value(v, k)
                          end

        define_attribute_methods
      end

      def to_s
        "#{self.class.name.split("::").last} ##{id}"
      end

      def id
        attributes[:id] || attributes["id"]
      end

      def ==(other)
        self.class == other.class && !id.nil? && id == other.id
      end

      def to_h
        attributes.transform_values do |value|
          case value
          when BaseEntity then value.to_h
          when Array then value.map { |item| item.is_a?(BaseEntity) ? item.to_h : item }
          else value
          end
        end
      end

      def to_json(*options)
        to_h.to_json(*options)
      end

      def inspect
        "#<#{self.class.name}:#{object_id} @attributes=#{@attributes.inspect}>"
      end

      # Saves changes to the entity back to the API
      def save
        return self if id.nil? || client.nil?

        collection_name = ActiveSupport::Inflector.tableize(self.class.name.split("::").last).to_sym

        if client.respond_to?(collection_name)
          updated = client.send(collection_name).update(id, attributes)
          @attributes = updated.attributes if updated
        end

        self
      end

      # Updates attributes and saves
      def update(new_attributes)
        new_attributes.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
        save
      end

      # Deletes the entity from the API
      def destroy
        return false if id.nil? || client.nil?

        collection_name = ActiveSupport::Inflector.tableize(self.class.name.split("::").last).to_sym

        if client.respond_to?(collection_name)
          client.send(collection_name).delete(id)
          true
        else
          false
        end
      end

      # Reloads the entity from the API
      def reload
        return self if id.nil? || client.nil?

        collection_name = ActiveSupport::Inflector.tableize(self.class.name.split("::").last).to_sym

        if client.respond_to?(collection_name)
          reloaded = client.send(collection_name).find(id)
          @attributes = reloaded.attributes if reloaded
        end

        self
      end

      # Association helper for single objects
      def association(association_name, target_class_name_override = nil)
        @_association_cache ||= {}
        return @_association_cache[association_name] if @_association_cache.key?(association_name)

        association_data = attributes[association_name]

        return @_association_cache[association_name] = association_data if association_data.is_a?(BaseEntity)

        if association_data.is_a?(Hash) && association_data[:id]
          assoc_id = association_data[:id]
          target_class_name = target_class_name_override || ActiveSupport::Inflector.classify(association_name.to_s)
          collection_name = ActiveSupport::Inflector.tableize(target_class_name).to_sym

          if client&.respond_to?(collection_name)
            fetched = client.send(collection_name).find(assoc_id)
            return @_association_cache[association_name] = fetched
          end
        end

        @_association_cache[association_name] = nil
      end

      # Association helper for collections
      def has_many(association_name, foreign_key = nil, target_class_name_override = nil)
        @_association_cache ||= {}
        return @_association_cache[association_name] if @_association_cache.key?(association_name)

        association_data = attributes[association_name]
        if association_data.is_a?(Array) && association_data.all? { |item| item.is_a?(BaseEntity) }
          return @_association_cache[association_name] = association_data
        end

        target_class_name = target_class_name_override || ActiveSupport::Inflector.classify(association_name.to_s)
        collection_name = ActiveSupport::Inflector.tableize(target_class_name).to_sym
        fk = foreign_key || :"#{ActiveSupport::Inflector.underscore(self.class.name.split("::").last)}_id"

        if client&.respond_to?(collection_name)
          @_association_cache[association_name] = client.send(collection_name).where(fk => id)
        else
          @_association_cache[association_name] = []
        end
      end

      private

      def define_attribute_methods
        attributes.each_key do |key|
          next if key.nil? || respond_to?(key)

          define_singleton_method(key) { attributes[key] }
          define_singleton_method("#{key}=") { |v| attributes[key] = process_value(v, key) }
        end
      end

      def process_value(value, key_hint = nil)
        case value
        when Hash
          klass = entity_class_for(value, key_hint)
          if klass
            klass.new(value, client: client)
          else
            value.transform_keys(&:to_sym)
                 .each_with_object({}) do |(k, v), acc|
                   acc[k] = process_value(v, k)
                 end
          end
        when Array
          singular_hint = key_hint ? ActiveSupport::Inflector.singularize(key_hint.to_s).to_sym : nil
          value.map { |item| process_value(item, singular_hint) }
        else
          value
        end
      end

      def entity_class_for(data, key_hint = nil)
        type_name = data[:type] || data["type"]

        if type_name.nil? && key_hint
          type_name = case key_hint
                      when :ownerc, :adminc, :techc, :zonec
                        "Contact"
                      when :nameServers, :name_servers
                        "NameServer"
                      when :resourceRecords, :resource_records
                        "ZoneRecord"
                      else
                        ActiveSupport::Inflector.singularize(key_hint.to_s)
                      end
        end

        return nil unless type_name

        class_name = ActiveSupport::Inflector.classify(type_name)

        if ENTITIES.key?(class_name)
          ENTITIES[class_name]
        else
          nil
        end
      end
    end
  end
end
