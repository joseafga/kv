module KV
  ENDPOINT = "https://api.cloudflare.com/client/v4"

  class_getter config = Configuration.new

  # Customize settings using a block.
  #
  # ```
  # KV.configure do |config|
  #   config.account_id = "023e105f4ecef8ad9ca31a8372d0c353"
  #   config.api_token = "Sn3lZJTBX6kkg7OdcBUAxOO963GEIyGQqnFTOFYY"
  # end
  # ```
  def self.configure(&) : Nil
    yield config
  end

  class Configuration
    getter account_id : String = ""
    property api_token : String = ""
    getter! endpoint : String

    def account_id=(account_id)
      @account_id = account_id
      @endpoint = "#{ENDPOINT}/accounts/#{account_id}/storage/kv"
    end
  end
end
