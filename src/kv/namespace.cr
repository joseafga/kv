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
  end
end
