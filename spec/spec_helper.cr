require "spec"
require "../src/kv"

KV.configure do |config|
  config.account_id = ENV["ACCOUNT_ID"]
  config.api_token = ENV["API_TOKEN"]
end

module Samples
  extend self
  PATH = Path[__DIR__] / "samples"

  def load_json(filename) : String
    File.read("#{PATH}/#{filename}.json")
  end
end
