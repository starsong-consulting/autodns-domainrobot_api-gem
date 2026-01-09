# autodns-domainrobot_api

Ruby client for the InternetX AutoDNS Domain Robot REST API.

## Installation

Add to your Gemfile:

```ruby
gem "autodns-domainrobot_api"
```

Or install directly:

```bash
gem install autodns-domainrobot_api
```

## Usage

### Basic Setup

```ruby
require "autodns-domainrobot_api"

client = Autodns::DomainrobotApi::Client.new(
  url: "https://api.autodns.com/v1",  # or https://api.demo.autodns.com/v1
  username: "your_username",
  password: "your_password",
  context: "4"
)

# Test connection
client.test_connection  # => true
```

### Domains

```ruby
# List all domains (handles pagination automatically)
client.domains.all

# Find a specific domain
domain = client.domains.find("example.com")
domain.name           # => "example.com"
domain.expire_date    # => Date
domain.auto_renew?    # => true/false
domain.registry_status
domain.nameserver_names  # => ["ns1.example.com", "ns2.example.com"]

# Query with filters
client.domains.where(name: "*.com").all
client.domains.where(name: "example.*").limit(10).all

# Request specific fields only (reduces response size)
client.domains.keys(:name, :payable, :autoRenewStatus).all

# Access contacts
domain.ownerc   # => Contact (registrant)
domain.adminc   # => Contact (admin)
domain.techc    # => Contact (technical)
domain.zonec    # => Contact (zone/billing)
```

### Contacts

```ruby
# Find a contact by ID
contact = client.contacts.find(123)
contact.full_name     # => "John Doe"
contact.organization
contact.email
contact.phone
contact.address       # => ["123 Main St", "Suite 100"]
contact.city
contact.country

# List contacts
client.contacts.all
client.contacts.where(lname: "Doe").all
```

### DNS Zones

```ruby
# Find a zone
zone = client.zones.find("example.com")
zone.origin           # => "example.com"
zone.soa_email
zone.records          # => [ZoneRecord, ...]

# Access zone records
zone.records.each do |record|
  puts "#{record.type} #{record.name} -> #{record.value}"
end
```

### SSL Certificates

```ruby
# Find a certificate
cert = client.certificates.find(456)
cert.common_name
cert.san              # Subject Alternative Names
cert.valid_from
cert.valid_until
cert.status
```

### Jobs (Async Operations)

```ruby
# List jobs
client.jobs.all

# Check job status
job = client.jobs.find(789)
job.status        # => "RUNNING", "SUCCESS", "FAILED"
job.successful?
job.failed?
job.running?
```

### Poll Messages

```ruby
# Retrieve notifications
client.poll_messages.all
```

## Rate Limiting

AutoDNS allows 3 requests per second. The gem automatically handles this when fetching all records via pagination (0.35s delay between requests).

## Error Handling

```ruby
begin
  client.domains.find("nonexistent.com")
rescue Autodns::DomainrobotApi::NotFoundError
  puts "Domain not found"
rescue Autodns::DomainrobotApi::AuthenticationError
  puts "Invalid credentials"
rescue Autodns::DomainrobotApi::RateLimitError
  puts "Too many requests"
rescue Autodns::DomainrobotApi::Error => e
  puts "API error: #{e.message}"
end
```

## Debug Mode

Enable debug logging to see API requests:

```ruby
client = Autodns::DomainrobotApi::Client.new(
  username: "user",
  password: "pass",
  context: "4",
  debug: true
)
```

## Development

```bash
bundle install
bundle exec rake test
```

## License

Apache-2.0. See [LICENSE](LICENSE) for details.
