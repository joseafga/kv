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

    # Get the namespace corresponding to the given ID.
    def get(namespace_id : String) : Namespace
      url = URI.parse("#{KV.config.endpoint}/namespaces/#{namespace_id}")

      response = request(url: url)
      Response(Namespace).from_json(response).result
    end

    # Creates a namespace under the given title.
    # A `400` is returned if the account already owns a namespace with this title. A
    # namespace must be explicitly deleted to be replaced.
    def create(title : String) : Namespace
      url = URI.parse("#{KV.config.endpoint}/namespaces")

      response = request(method: "POST", url: url, body: { title: title }.to_json)
      Response(Namespace).from_json(response).result
    end

    # Modifies a namespace's title.
    def rename(namespace_id : String, title : String) : Namespace
      url = URI.parse("#{KV.config.endpoint}/namespaces/#{namespace_id}")

      response = request(method: "PUT", url: url, body: { title: title }.to_json)
      Response(Namespace).from_json(response).result
    end

    # Deletes the namespace corresponding to the given ID.
    def delete(namespace_id : String) : Nil
      url = URI.parse("#{KV.config.endpoint}/namespaces/#{namespace_id}")

      response = request(method: "DELETE", url: url)
      Response(Nil).from_json(response).result
    end

    # Lists a namespace's keys.
    #
    # Opaque token indicating the position from which to continue when requesting the
    # next set of records if the amount of list results was limited by the limit
    # parameter. A valid value for the *cursor* can be obtained from the cursors object in
    # the result_info structure.
    #
    # Limits the number of keys returned in the response. The cursor attribute may be
    # used to iterate over the next batch of keys if there are more than the *limit*.
    #
    # Filters returned keys by a name *prefix*. Exact matches and any key names that begin
    # with the *prefix* will be returned.
    def keys(namespace_id : String, cursor : String? = nil, limit : Int32? = nil, prefix : String? = nil) : Array(Namespace::Key)
      url = URI.parse("#{KV.config.endpoint}/namespaces/#{namespace_id}/keys")
      query = URI::Params.build do |q|
        q.add "cursor", cursor unless cursor.nil?
        q.add "limit", limit.to_s unless limit.nil?
        q.add "prefix", prefix unless prefix.nil?
      end
      url.query = query unless query.empty?

      response = request(url: url)
      Response(Array(Namespace::Key)).from_json(response).result
    end

    # Returns the value associated with the given key in the given namespace. Use
    # URL-encoding to use special characters (for example, :, !, %) in the key name. If
    # the KV-pair is set to expire at some point, the expiration time as measured in
    # seconds since the UNIX epoch will be returned in the expiration response header.
    def read(namespace_id : String, key_name : String) : String
      url = URI.parse("#{KV.config.endpoint}/namespaces/#{namespace_id}/values/#{key_name}")

      request(url: url)
    end

    # Write a value identified by a key. Use URL-encoding to use special characters (for
    # example, :, !, %) in the key name. Body should be the value to be stored. If JSON
    # metadata to be associated with the key/value pair is needed, use
    # `multipart/form-data` content type for your PUT request (see dropdown below in
    # REQUEST BODY SCHEMA). Existing values, expirations, and metadata will be
    # overwritten.
    # If neither *expiration* nor *expiration_ttl* is specified, the key-value pair will
    # never expire. If both are set, *expiration_ttl* is used and *expiration* is ignored.
    #
    # *expiration*: Expires the key at a certain time, measured in number of seconds since the UNIX epoch.
    #
    # *expiration_ttl*: Expires the key after a number of seconds. Must be at least 60.
    def write(namespace_id : String, key_name : String, value : String, metadata : String? = nil, expiration : Int64? = nil, expiration_ttl : Int64? = nil) : Nil
      url = URI.parse("#{KV.config.endpoint}/namespaces/#{namespace_id}/values/#{key_name}")
      query = URI::Params.build do |q|
        q.add "expiration", expiration.to_s unless expiration.nil?
        q.add "expiration_ttl", expiration_ttl.to_s unless expiration_ttl.nil?
      end
      url.query = query unless query.empty?

      if metadata
        io = IO::Memory.new
        builder = HTTP::FormData::Builder.new(io, "AaB03x")
        builder.field("value", value)
        builder.field("metadata", metadata) unless metadata.nil?
        builder.finish

        response = request(method: "PUT", url: url, body: io.to_s, headers: HTTP::Headers{
          "Content-Type" => builder.content_type,
          "Authorization" => "Bearer #{KV.config.api_token}"
        })
      else
        response = request(method: "PUT", url: url, body: value, headers: HTTP::Headers{
          "Content-Type" => "application/octet-stream",
          "Authorization" => "Bearer #{KV.config.api_token}"
        })
      end

      Response(Nil).from_json(response).result
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
      Log.debug { %(Received: #{content_type.media_type} <- "#{response.body}") }

      case content_type.media_type
      when "application/json"
        response.body
      when "application/octet-stream"
        response.body
      else
        raise "Unknown Content-Type: #{content_type.media_type}"
      end
    end
  end

  extend API
end
