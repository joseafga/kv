require "json"

module KV
  struct Response(T)
    include JSON::Serializable

    getter errors = [] of ResponseInfo
    getter messages = [] of ResponseInfo
    property result : T
    # Whether the API call was successful
    getter? success : Bool
    # *(Optional)*
    getter result_info : ResultInfo?

    # Shared
    struct ResponseInfo
      include JSON::Serializable

      getter code : Int32 # (minimum: 1000)
      getter message : String
      # *(Optional)*
      getter documentation_url : String?
      # *(Optional)*
      getter source : Source?
    end

    struct Source
      include JSON::Serializable

      # *(Optional)*
      getter pointer : String?
    end

    struct ResultInfo
      include JSON::Serializable

      # *(Optional)*
      getter count : Int32?
      # *(Optional)*
      getter page : Int32?
      # *(Optional)*
      getter per_page : Int32?
      # *(Optional)*
      getter total_count : Int32?
    end
  end

  struct ResultBulk
    include JSON::Serializable

    # Number of keys successfully updated. *(Optional)*
    getter successful_key_count : Int32?
    # Name of the keys that failed to be fully updated. They should be retried. *(Optional)*
    getter unsuccessful_keys : Array(String)
  end

  struct ResultGetBulk(T)
    include JSON::Serializable

    getter values : Hash(String, T?)

    struct WithMetadata
      include JSON::Serializable

      getter value : String | JSON::Any

      @[JSON::Field(converter: Time::EpochConverter)]
      getter expiration : Time?

      getter metadata : JSON::Any?
    end
  end
end
