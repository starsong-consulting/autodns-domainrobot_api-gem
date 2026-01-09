# frozen_string_literal: true

require "test_helper"

class ClientTest < Test::Unit::TestCase
  def setup
    @client = Autodns::DomainrobotApi::Client.new(
      url: "https://api.autodns.com/v1",
      username: "testuser",
      password: "testpass",
      context: "4"
    )
  end

  def test_client_initializes
    assert_not_nil @client
    assert_not_nil @client.connection
  end

  def test_client_responds_to_domains
    assert @client.respond_to?(:domains)
  end

  def test_client_responds_to_contacts
    assert @client.respond_to?(:contacts)
  end

  def test_client_responds_to_zones
    assert @client.respond_to?(:zones)
  end

  def test_client_responds_to_certificates
    assert @client.respond_to?(:certificates)
  end

  def test_domains_returns_collection_proxy
    assert_instance_of Autodns::DomainrobotApi::CollectionProxy, @client.domains
  end

  def test_contacts_returns_collection_proxy
    assert_instance_of Autodns::DomainrobotApi::CollectionProxy, @client.contacts
  end

  def test_test_connection
    stub_request(:get, "https://api.autodns.com/v1/hello")
      .to_return(
        status: 200,
        body: { status: { type: "success" } }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    assert @client.test_connection
  end

  def test_authentication_error
    stub_request(:get, "https://api.autodns.com/v1/hello")
      .to_return(status: 401, body: "Unauthorized")

    assert_raise(Autodns::DomainrobotApi::AuthenticationError) do
      @client.get("hello")
    end
  end

  def test_rate_limit_error
    stub_request(:get, "https://api.autodns.com/v1/hello")
      .to_return(status: 429, body: "Too Many Requests")

    assert_raise(Autodns::DomainrobotApi::RateLimitError) do
      @client.get("hello")
    end
  end
end
