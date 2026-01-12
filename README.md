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

# Advanced domain operations
domain.renew!                          # Renew domain
domain.create_authinfo1!               # Generate transfer key
domain.delete_authinfo1!               # Delete transfer key
domain.send_authinfo_to_owner!         # Email authinfo to registrant
domain.add_to_domain_safe!             # Enable transfer lock
domain.remove_from_domain_safe!        # Disable transfer lock
domain.dnssec_key_rollover!            # Trigger DNSSEC key rollover
domain.update_comment!("My comment")   # Update domain comment
domain.change_owner!(new_contact)      # Change registrant
domain.update_status!("clientHold")    # Update registry status
domain.restore!                        # Restore deleted domain

# Class methods for domain operations
Autodns::DomainrobotApi::Domain.transfer(client, domain_data)
Autodns::DomainrobotApi::Domain.import(client, domain_data)
Autodns::DomainrobotApi::Domain.trade(client, domain_data)
Autodns::DomainrobotApi::Domain.autodelete_list(client)
Autodns::DomainrobotApi::Domain.restore_list(client)
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

# Zone stream operations (incremental updates)
zone.add_records!([
  { name: "www", type: "A", value: "1.2.3.4", ttl: 3600 }
])
zone.remove_records!([
  { name: "old", type: "A", value: "5.6.7.8" }
])
zone.stream!(
  adds: [{ name: "new", type: "CNAME", value: "target.com." }],
  removes: [{ name: "old", type: "A", value: "1.2.3.4" }]
)

# Partial zone update
zone.patch!(soaEmail: "admin@example.com")

# Import existing zone
Autodns::DomainrobotApi::Zone.import(client, "example.com", "ns1.example.com")
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

# Certificate operations
cert.reissue!                         # Reissue with new CSR
cert.renew!                           # Renew certificate
cert.update_comment!("Production")    # Update comment

# Prepare order (generates DCV data)
dcv_data = Autodns::DomainrobotApi::Certificate.prepare_order(client, {
  plain: csr_content,
  product: "BASIC_SSL"
})

# Order certificate in realtime (DV certs only)
cert = Autodns::DomainrobotApi::Certificate.realtime(client, certificate_data)
```

### SSL Contacts

```ruby
# List SSL contacts
client.ssl_contacts.all

# Find an SSL contact
ssl_contact = client.ssl_contacts.find(123)
ssl_contact.full_name
ssl_contact.organization
ssl_contact.email
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

### WHOIS Lookup

```ruby
# Single domain lookup
whois = client.whois("example.com")
whois.domain
whois.status          # => "FREE", "ASSIGNED", etc.
whois.available?      # => true/false

# Multiple domain lookup
results = client.whois_multi(["example.com", "example.net", "example.org"])
results.each do |w|
  puts "#{w.domain}: #{w.status}"
end
```

### Domain Studio (Domain Suggestions)

```ruby
# Search for domain suggestions
suggestions = client.domain_studio("mybusiness")
suggestions.each do |s|
  puts "#{s.domain} - #{s.available? ? 'Available' : 'Taken'}"
end

# With options
suggestions = client.domain_studio("mybusiness",
  only_available: true,
  currency: "EUR",
  ignore_premium: true
)

# Or use class method directly
Autodns::DomainrobotApi::DomainStudio.search(client, "keyword", options)
```

### URL Redirects

```ruby
# List redirects
client.redirects.all

# Find a redirect
redirect = client.redirects.find(123)
redirect.source
redirect.target
redirect.redirect_type    # => 301, 302
```

### Transfer Out

```ruby
# List outgoing transfer requests
client.transfer_outs.all

# Handle transfer request
transfer = client.transfer_outs.find("example.com")
transfer.domain
transfer.status
transfer.gaining_registrar
transfer.ack_deadline

# Approve or deny
transfer.approve!
transfer.deny!
```

### Domain Cancelation

```ruby
# Create a cancelation request
cancelation = Autodns::DomainrobotApi::DomainCancelation.create(client, "example.com",
  type: "DELETE",
  exec_date: Date.today + 30
)

# Get cancelation info
cancelation = Autodns::DomainrobotApi::DomainCancelation.info(client, "example.com")

# List all cancelations
cancelations = Autodns::DomainrobotApi::DomainCancelation.list(client)

# Update or delete cancelation
cancelation.save!
cancelation.delete!
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
