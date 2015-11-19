require 'virtus'
require "trimark/version"
require "trimark/client"

module Trimark
  class << self
    def underscore(str)
      word = str.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    def symbolize_keys(params)
      {}.tap do |hsh|
        params.keys.each { |k| hsh[underscore(k).to_sym] = params[k] }
      end
    end
  end
end
