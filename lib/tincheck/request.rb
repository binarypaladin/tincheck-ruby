# frozen-string-literal: true

require 'tincheck/response'
require 'tincheck/xml'

module TINCheck
  class Request
    SERVICES = {
      list_match: 'ValidateListMatch',
      status: 'ServiceStatus',
      tin_name: 'ValidateTinName',
      validate_all: 'ValidateTinNameAddressListMatch'
    }.freeze

    SERVICE_XMLNS = 'http://www.TinCheck.com/WebServices/PVSService/'.freeze

    InvalidConfig = Class.new(StandardError)
    ResponseError = Class.new(StandardError)

    attr_reader :config, :http, :serializer

    def initialize(config = TINCheck.default_config, http: nil, serializer: nil)
      raise InvalidConfig, 'invalid or missing config' unless config.is_a?(Config)
      @config = config
      @http = http || _http
      @parser = XML.parser_with(config.xml_lib)
      @serializer = serializer || XML.serializer_with(config.xml_lib)
    end

    def call(request_hash)
      r = post(serializer.(format_request(request_hash)))
      Response.with_http_response(r, parser: @parser)
    end

    def post(xml)
      http.dup.start { |h| h.request(post_request(xml)) }
    end

    def status(*)
      call(SERVICES[:status] => {})
    end

    def tin_name(**kwargs)
      require_arguments!(kwargs, :name, :tin)
      call(SERVICES[:tin_name] => tin_name_arg(**kwargs))
    end

    private

    def _http
      Net::HTTP.new(config.uri.host, config.uri.port, *config.proxy_args).tap do |h|
        h.use_ssl = true if config.uri.scheme == 'https'
      end
    end

    def auth_args
      raise InvalidConfig, 'no username or password specified in config' unless
        config.username && config.password
      {
        'CurUser' => {
          'UserLogin' => config.username,
          'UserPassword' => config.password
        }
      }
    end

    def format_request(request_hash)
      soap_envelop(inject_auth_args(request_hash))
    end

    def inject_auth_args(request_hash)
      k, h = request_hash.first
      return request_hash if h.key?('CurUser')
      request_hash.merge(k => h.merge(auth_args))
    end

    def post_request(xml)
      Net::HTTP::Post.new(config.uri.path).tap do |r|
        r['Content-Type'] ||= 'text/xml; charset=UTF-8'
        r.body = xml
      end
    end

    def require_arguments!(kwargs, *keys)
      keys.each { |k| raise ArgumentError, "missing keyword: #{k}" unless kwargs.key?(k) }
      kwargs
    end

    def soap_envelop(request_hash)
      {
        'SOAP-ENV:Envelope' => {
          'xmlns:SOAP-ENC' => 'http://schemas.xmlsoap.org/soap/encoding/',
          'xmlns:SOAP-ENV' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'SOAP-ENV:Body' => request_hash.merge('xmlns' => SERVICE_XMLNS)
        }
      }
    end

    def tin_name_arg(giin: nil, name:, tin: nil, **)
      {
        'TinName' => {
          'TIN' => tin,
          'LName' => name,
          'GIIN' => giin
        }
      }
    end
  end
end
