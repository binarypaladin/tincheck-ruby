# frozen-string-literal: true

require 'net/http'
require 'uri'

module TINCheck
  class Config
    OPTS = %i[password proxy_url url username xml_lib].freeze
    SERVICE_URI = URI.parse('https://www.tincheck.com/pvsws/pvsservice.asmx').freeze

    class Builder
      def self.call(&blk)
        new.(&blk)
      end

      def initialize
        @opts = {}
      end

      OPTS.each { |o| define_method(o) { |val| @opts[o] = val.to_s } }

      def call(&blk)
        instance_eval(&blk) if block_given?
        Config.new(@opts)
      end
    end

    class << self
      def build(&blk)
        Config::Builder.(&blk)
      end

      def with_obj(config)
        config.is_a?(self) ? config : new(config)
      end
    end

    attr_reader :proxy_uri

    def initialize(**opts)
      @opts = opts.each_with_object({}) do |(k, v), h|
        OPTS.include?(k = k.to_sym) && h[k] = v.to_s
      end
      defaults!
      load_xml_lib
      proxy_uri!
    end

    def opts
      @opts.dup
    end

    def proxy_args
      @proxy_uri ? [@proxy_uri.host, @proxy_uri.port, @proxy_uri.user, @proxy_uri.password] : []
    end

    def with(**opts)
      self.class.new(@opts.merge(opts))
    end

    (OPTS + [:uri]).each { |o| define_method(o) { @opts[o] } }

    private

    def default_uri(url)
      url ? URI(url) : SERVICE_URI
    end

    def default_xml_lib
      return 'Ox' if defined?(::Ox)
      return 'Nokogiri' if defined?(::Nokogiri)
      'REXML'
    end

    def defaults!
      @opts[:xml_lib] ||= default_xml_lib
      @opts[:password] ||= ENV['tincheck_password']
      @opts[:username] ||= ENV['tincheck_username']
      @opts[:uri] ||= default_uri(@opts[:url])
    end

    def load_xml_lib
      require "tincheck/xml/#{@opts[:xml_lib].downcase}"
    end

    def proxy_uri!
      return unless (url = @opts[:proxy_url] || ENV['HTTP_PROXY'] || ENV['http_proxy'])
      @proxy_uri = URI(url)
    end
  end
end
