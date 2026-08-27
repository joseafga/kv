require "json"

module KV
  struct Namespace
    include JSON::Serializable

    # Namespace identifier tag.
    getter id : String
    # A human-readable string name for a Namespace.
    getter title : String
    # True if keys written on the URL will be URL-decoded before storing.For example,
    # if set to "true", a key written on the URL as "%3F" will be stored as "?".
    getter? supports_url_encoding : Bool?

    struct Key
      include JSON::Serializable

      # A key's *name*. The name may be at most 512 bytes. All printable, non-whitespace
      # characters are valid. Use percent-encoding to define key names as part of a URL.
      # (maxLength: 512)
      getter name : String

      # The time, measured in number of seconds since the UNIX epoch, at which the key will
      # expire. This property is omitted for keys that will not expire.
      @[JSON::Field(converter: Time::EpochConverter)]
      getter expiration : Time?

      # Arbitrary JSON that is associated with a key.
      getter metadata : JSON::Any?
    end
  end

  module Bulk
    # Key, but to be written in a bulk operation.
    struct Key
      include JSON::Serializable

      # A key's *name*. The name may be at most 512 bytes. All printable, non-whitespace
      # characters are valid. Use percent-encoding to define key names as part of a URL.
      # (maxLength: 512)
      getter key : String

      # A UTF-8 encoded string to be stored, up to 25 MiB in length.
      # (maxLength: 26214400)
      getter value : String

      # Indicates whether or not the server should base64 decode the value before storing
      # it. Useful for writing values that wouldn’t otherwise be valid JSON strings, such
      # as images.
      getter base64 : Bool?

      # Expires the key at a certain time, measured in number of seconds since the UNIX epoch.
      @[JSON::Field(converter: Time::EpochConverter)]
      getter expiration : Time?

      # Expires the key after a number of seconds. Must be at least 60.
      # (minimum: 60)
      getter expiration_ttl : Int32?

      # Arbitrary JSON that is associated with a key.
      getter metadata : JSON::Any?

      def initialize(@key : String, value, @base64 = nil, @expiration = nil, @expiration_ttl = nil, @metadata = nil)
        @value = value.to_s
      end
    end
  end
end
