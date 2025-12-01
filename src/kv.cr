require "log"
require "./kv/configuration"
require "./kv/namespace"
require "./kv/response"
require "./kv/api"

module KV
  VERSION = "0.1.0"
  Log     = ::Log.for("kv")

  class ResponseError < Exception
    getter info : Array(Response::ResponseInfo)

    def initialize(@info)
      if info.empty?
        @message = "Unknown Response Error."
      else
        @message = "Error #{info.first.code}: #{info.first.message}."
      end
    end
  end
end
