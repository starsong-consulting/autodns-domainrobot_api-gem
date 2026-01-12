# frozen_string_literal: true

require_relative 'lib/autodns/domainrobot_api/version'

Gem::Specification.new do |spec|
  spec.name = 'autodns-domainrobot_api'
  spec.version = Autodns::DomainrobotApi::VERSION
  spec.authors = ['Teal Bauer']
  spec.email = ['rubygems@teal.is']

  spec.summary = 'Ruby client for the InternetX AutoDNS Domain Robot REST API'
  spec.description = 'A Ruby gem for interacting with the InternetX AutoDNS Domain Robot REST API (api.autodns.com/v1). Supports domain management, contacts, DNS zones, certificates, and more.'
  spec.homepage = 'https://github.com/starsong-consulting/autodns-domainrobot_api-gem'
  spec.license = 'Apache-2.0'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 7.0'
  spec.add_dependency 'faraday', '>= 2.0'
end
