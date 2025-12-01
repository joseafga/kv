require "json"
require "http/client"
require "mime/media_type"

module KV
  # This module provides most basic interface to the KV API.
  # Is preferred to use `KV::Database` when possible.
  module API
    extend self

    # Returns the namespaces owned by an account.
    #
    # *direction* to order namespaces.
    # ("asc" or "desc")
    #
    # Field to *order* results by.
    # ("id" or "title")
    #
    # *page* number of paginated results.
    # (minimum: 1, default: 1)
    #
    # Number of items *per_page*.
    # (maximum: 10000, minimum: 10, default: 1000)
    def list(direction : String? = nil, order : String? = nil, page : Int32? = nil, per_page : Int32? = nil) : Array(Namespace)
      url = URI.parse("#{KV.config.endpoint}/namespaces")
      query = URI::Params.build do |q|
        q.add "direction", direction unless direction.nil?
        q.add "order", order unless order.nil?
        q.add "page", page.to_s unless page.nil?
        q.add "per_page", per_page.to_s unless per_page.nil?
      end
      url.query = query unless query.empty?

      response = request(url: url)
      Response(Array(Namespace)).from_json(response).result
    end

    private def request(**params)
      args = { # default params
        method: "GET",
        url: KV.config.endpoint,
        headers: HTTP::Headers{
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{KV.config.api_token}"
        }
      }.merge(params)
      Log.debug { "Requesting -> #{args}" }

      response = HTTP::Client.exec(**args)
      content_type = MIME::MediaType.parse(response.headers["Content-Type"])

      case content_type.media_type
      when "application/json"
        Log.debug { "Received <- #{response.body}" }

        response.body
      else
        raise "Unknown Content-Type: #{content_type.media_type}"
      end
    end
  end

  extend API
end
