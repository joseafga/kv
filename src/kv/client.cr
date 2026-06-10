require "http/client"
require "mime/media_type"

module KV
  ENDPOINT = "https://api.cloudflare.com/client/v4/accounts/%s/storage/kv" # %s -> account_id

  class Client
    property endpoint
    property headers
    getter http_client

    def initialize(account_id : String, api_token : String)
      @endpoint = URI.parse(ENDPOINT % account_id)
      @headers = HTTP::Headers{"Content-Type" => "application/json"}
      @http_client = HTTP::Client.new @endpoint

      @http_client.before_request do |request|
        request.headers["Authorization"] = "Bearer #{api_token}"
      end
    end

    protected def request(path : String, **params) : String
      args = { # default params
        method:  "GET",
        path:    @endpoint.path + path,
        headers: @headers,
      }.merge(params)
      Log.debug { "Requesting -> #{args}" }

      response = http_client.exec(**args)
      content_type = MIME::MediaType.parse(response.headers["Content-Type"])
      Log.debug { %(Received: #{content_type.media_type} <- "#{response.body}") }

      case content_type.media_type
      when "application/json"
        raise ResponseError.new(Response(Nil).from_json(response.body).errors) unless response.success?

        response.body
      when "application/octet-stream"
        response.body
      else
        raise "Unknown Content-Type: #{content_type.media_type}"
      end
    end
  end
end
