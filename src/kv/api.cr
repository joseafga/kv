module KV
  class Client
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
      path = "/namespaces"

      query = URI::Params.build do |q|
        q.add "direction", direction unless direction.nil?
        q.add "order", order unless order.nil?
        q.add "page", page.to_s unless page.nil?
        q.add "per_page", per_page.to_s unless per_page.nil?
      end
      path += "?#{query}" unless query.empty?

      response = request(path)
      Response(Array(Namespace)).from_json(response).result.tap do |arr|
        arr.each(&.with_client(self))
      end
    end

    def list(direction : String? = nil, order : String? = nil, page : Int32? = nil, per_page : Int32? = nil, &)
      yield list(direction, order, page, per_page)
    end

    # Get the namespace corresponding to the given ID.
    def get(namespace_id : String) : Namespace
      path = "/namespaces/#{namespace_id}"

      response = request(path)
      Response(Namespace).from_json(response).result.with_client(self)
    end

    def get(namespace_id : String, &)
      yield get(namespace_id)
    end

    # Creates a namespace under the given title.
    # A `400` is returned if the account already owns a namespace with this title. A
    # namespace must be explicitly deleted to be replaced.
    def create(title : String) : Namespace
      path = "/namespaces"

      response = request(path, method: "POST", body: {title: title}.to_json)
      Response(Namespace).from_json(response).result.with_client(self)
    end

    # Modifies a namespace's title.
    def rename(namespace_id : String, title : String) : Namespace
      path = "/namespaces/#{namespace_id}"

      response = request(path, method: "PUT", body: {title: title}.to_json)
      Response(Namespace).from_json(response).result.with_client(self)
    end

    # Deletes the namespace corresponding to the given ID.
    def delete(namespace_id : String) : Nil
      path = "/namespaces/#{namespace_id}"

      response = request(path, method: "DELETE")
      Response(Nil).from_json(response).result
    end
  end

  struct Namespace
    # Keep client for internal requests
    @[JSON::Field(ignore: true)]
    getter! client : Client?

    # Set client keeping context
    def with_client(client : Client) : self
      @client = client
      self
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
    def keys(cursor : String? = nil, limit : Int32? = nil, prefix : String? = nil) : Array(Namespace::Key)
      path = "/namespaces/#{id}/keys"
      query = URI::Params.build do |q|
        q.add "cursor", cursor unless cursor.nil?
        q.add "limit", limit.to_s unless limit.nil?
        q.add "prefix", prefix unless prefix.nil?
      end
      path += "?#{query}" unless query.empty?

      response = client.request(path)
      Response(Array(Namespace::Key)).from_json(response).result
    end

    # Returns the value associated with the given key in the given namespace. Use
    # URL-encoding to use special characters (for example, :, !, %) in the key name. If
    # the KV-pair is set to expire at some point, the expiration time as measured in
    # seconds since the UNIX epoch will be returned in the expiration response header.
    def read(key_name : String) : String
      path = "/namespaces/#{id}/values/#{key_name}"

      client.request(path)
    end

    # Returns the metadata associated with the given key in the given namespace. Use
    # URL-encoding to use special characters (for example, :, !, %) in the key name.
    def metadata(key_name : String) : JSON::Any?
      path = "/namespaces/#{id}/metadata/#{key_name}"

      response = client.request(path)
      Response(JSON::Any?).from_json(response).result
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
    def write(key_name : String, value, metadata = nil, expiration : Int64? = nil, expiration_ttl : Int64? = nil) : Nil
      path = "/namespaces/#{id}/values/#{key_name}"

      query = URI::Params.build do |q|
        q.add "expiration", expiration.to_s unless expiration.nil?
        q.add "expiration_ttl", expiration_ttl.to_s unless expiration_ttl.nil?
      end
      path += "?#{query}" unless query.empty?

      if metadata
        io = IO::Memory.new
        boundary = MIME::Multipart.generate_boundary
        builder = HTTP::FormData::Builder.new(io, boundary)
        builder.field("value", value.to_s)
        builder.field("metadata", metadata.to_json)
        builder.finish

        headers = HTTP::Headers{"Content-Type" => builder.content_type}
        response = client.request(path, method: "PUT", headers: headers, body: io.to_s)
      else
        headers = HTTP::Headers{"Content-Type" => "application/octet-stream"}
        response = client.request(path, method: "PUT", headers: headers, body: value.to_s)
      end

      Response(Nil).from_json(response).result
    end

    # Deletes the namespace corresponding to the given ID.
    def delete(key_name : String) : Nil
      path = "/namespaces/#{id}/values/#{key_name}"

      response = client.request(path, method: "DELETE")
      Response(Nil).from_json(response).result
    end

    # Retrieve up to 100 KV pairs from the namespace. Keys must contain text-based values.
    # JSON values can optionally be parsed instead of being returned as a string value.
    # Metadata can be included if `metadata` is `true`.
    #
    # *keys*: Array of keys to retrieve (maximum of 100).
    #
    # *type*: Whether to parse JSON values in the response.
    # ("text" or "json")
    #
    # *metadata*: Whether to include metadata in the response.
    def read_bulk(keys : Array(String), type : String = "json", metadata : Bool = false)
      path = "/namespaces/#{id}/bulk/get"
      body = {
        keys:         keys,
        type:         type,
        withMetadata: metadata,
      }

      response = client.request(path, method: "POST", body: body.to_json)
      Response(JSON::Any).from_json(response).result
    end

    # Write multiple keys and values at once. Body should be an array of up to 10,000
    # key-value pairs to be stored, along with optional expiration information. Existing
    # values and expirations will be overwritten. If neither `expiration` nor
    # `expiration_ttl` is specified, the key-value pair will never expire. If both are set,
    # `expiration_ttl` is used and `expiration` is ignored. The entire request size must
    # be 100 megabytes or less.
    def write_bulk(bulks : Array(BulkKey))
      path = "/namespaces/#{id}/bulk"

      response = client.request(path, method: "PUT", body: bulks.to_json)
      Response(ResultBulk).from_json(response).result
    end

    # TODO: Delete multiple key-value pairs
    def delete_bulk
    end
  end
end
