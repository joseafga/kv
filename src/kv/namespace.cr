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
end
