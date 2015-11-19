module Trimark
  class AuthError < StandardError; end
  class QueryError < StandardError; end

  class Site
    include APIConnection
    include Virtus.model

    attribute :site_id, Integer
    attribute :name, String
    attribute :site_type, String
    attribute :longitude, Float
    attribute :latitude, Float
    attribute :status_raw_value, Integer
    attribute :status, String
    attribute :status_type, String
    attribute :is_available, Boolean
    attribute :location, String

    def initialize(params = {})
      super(Trimark.symbolize_keys(params))
    end
  end
end
