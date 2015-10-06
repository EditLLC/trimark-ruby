require 'faraday'
require 'json'

module TriMark
  class AuthError < StandardError; end
  class QueryError < StandardError; end

  class Client

    attr_accessor :username, :password, :device_token, :device_id, :device_type

    def initialize
      yield(self) if block_given?
    end

    def login
    end

  end
end
