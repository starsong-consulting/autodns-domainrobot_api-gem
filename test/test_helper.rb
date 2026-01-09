# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "autodns-domainrobot_api"
require "test/unit"
require "webmock/test_unit"

WebMock.disable_net_connect!
