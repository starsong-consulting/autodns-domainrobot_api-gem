# frozen_string_literal: true

require 'faraday'
require 'json'
require 'base64'
require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

require_relative 'domainrobot_api/version'
require_relative 'domainrobot_api/connection'
require_relative 'domainrobot_api/client'
require_relative 'domainrobot_api/collection_proxy'
require_relative 'domainrobot_api/base_entity'

# Entity classes
require_relative 'domainrobot_api/entities/domain'
require_relative 'domainrobot_api/entities/contact'
require_relative 'domainrobot_api/entities/zone'
require_relative 'domainrobot_api/entities/zone_record'
require_relative 'domainrobot_api/entities/certificate'
require_relative 'domainrobot_api/entities/name_server'
require_relative 'domainrobot_api/entities/job'
require_relative 'domainrobot_api/entities/poll_message'
require_relative 'domainrobot_api/entities/whois'
require_relative 'domainrobot_api/entities/redirect'
require_relative 'domainrobot_api/entities/ssl_contact'
require_relative 'domainrobot_api/entities/transfer_out'
require_relative 'domainrobot_api/entities/domain_studio'
require_relative 'domainrobot_api/entities/domain_cancelation'

module Autodns
  module DomainrobotApi
    class Error < StandardError; end
    class AuthenticationError < Error; end
    class RateLimitError < Error; end
    class NotFoundError < Error; end

    # Entity class registry for dynamic lookup
    ENTITIES = {
      'Domain' => Domain,
      'Contact' => Contact,
      'Zone' => Zone,
      'ZoneRecord' => ZoneRecord,
      'Certificate' => Certificate,
      'NameServer' => NameServer,
      'Job' => Job,
      'PollMessage' => PollMessage,
      'Whois' => Whois,
      'Redirect' => Redirect,
      'SslContact' => SslContact,
      'TransferOut' => TransferOut,
      'DomainStudio' => DomainStudio,
      'DomainCancelation' => DomainCancelation
    }.freeze
  end
end
