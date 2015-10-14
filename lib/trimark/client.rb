require 'faraday'
require 'json'
require 'securerandom'
require 'trimark/connection'
require 'trimark/site'

module TriMark
  class AuthError < StandardError; end
  class QueryError < StandardError; end

  class Client
    include APIConnection
    attr_accessor :username, :password, :device_token, :access_token, :company_id

    def initialize
      yield(self) if block_given?
      @device_token = SecureRandom.uuid
    end

    def login_message
      {
        Username: username,
        Password: password,
        DeviceToken: device_token,
        DeviceId: '',
        DeviceType: 'Other'
      }
    end

    def login_header
      { 'Content-Type' => 'application/json' }
    end

    def login
      response = JSON.parse((conn.post 'login', login_message.to_json, login_header).body)
      if response['AccessToken'].nil?
        fail AuthError, "Login Failed! #{response['Message']}"
      else
        self.access_token = response['AccessToken']
      end
    end

    def site_url(site_id)
      "company/#{company_id}/site/#{site_id}"
    end

    def point_id_url(site_id, query_string)
      "company/#{company_id}/site/#{site_id}/history/?#{query_string}"
    end

    def url_picker(*args)
      if args && args.length <= 2
        args.length == 2 ? point_id_url(*args) : site_url(*args)
      else
        p args
        fail QueryError, 'Invalid / Too Many Arguments!'
      end
    end

    def query_headers
      {
        'Content-Type' => 'application/json',
        'access_token' => access_token,
        'device_token' => device_token
      }
    end

    # Returns site attributes and history data if an optional query_string is supplied
    def site_query(*args)
      response = (conn.get url_picker(*args), {}, query_headers).body
      if response['Message'] || response == 'null'
        fail QueryError,  "Query Failed! #{response}"
      else
        return JSON.parse(response)
      end
    end
  end
end
