require 'faraday'
require 'json'
require 'securerandom'
require 'trimark/connection'
require 'trimark/site'
require 'addressable/template'

module Trimark
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
        self.company_id = response['CompanyId']
        self.access_token = response['AccessToken']
      end
    end

    def base_url
      "company/#{company_id}" 
    end

    def site_info_url(site_id)
      "#{base_url}/site/#{site_id}"
    end

    def site_history_url(site_id, query_hash)
      Addressable::Template.new(
        "#{site_info_url(site_id)}/history/{?query*}"
      ).expand(query_hash)
    end

    def url_picker(*args)
      if args.length <= 2
        args.length == 2 ? site_history_url(*args) : site_info_url(*args)
      else
        fail QueryError, "#{args.length} Arguments Entered! Max 2"
      end
    end

    def query_headers
      fail QueryError, 'Login to set access token!' if access_token.nil?
      {
        'Content-Type' => 'application/json',
        'access_token' => access_token,
        'device_token' => device_token
      }
    end

    # Gets a list of all the sites for the company
    #
    def sites
      response = conn.get("#{base_url}/site", {}, query_headers)            
      body = JSON.parse(response.body)

      if body.is_a?(Array)
        body.map { |b| Site.new(b) } 
      else
        fail QueryError, "Query Failed! HTTPStatus: #{response.status} - Response: #{body}"
      end
    end

    # Returns site attributes and history data if an optional query_hash is supplied
    # @client.site_query(x) will return the attributes of site x
    # @client.site_query(x, query_hash) will return historical data from site x instrumentation
    def site_query(*args)
      response = conn.get(url_picker(*args), {}, query_headers)

      if response.body['SiteId'] || response.body['PointId']
        JSON.parse(response.body)
      else
        fail QueryError, "Query Failed! HTTPStatus: #{response.status}"
      end
    end
  end
end
