require "json"

module KV
  struct Response(T)
    include JSON::Serializable

    getter errors = [] of ResponseInfo
    getter messages = [] of ResponseInfo
    property! result : T
    # Whether the API call was successful
    getter? success : Bool
    # *(Optional)*
    getter result_info : ResultInfo?

    # Get result
    def to_result
      return result if success?

      raise ResponseError.new errors
    end

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
end
