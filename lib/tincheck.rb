# frozen-string-literal: true

require 'tincheck/config'
require 'tincheck/request'

module TINCheck
  class << self
    attr_reader :default_config, :default_request

    def configure(config = env_config, &blk)
      @default_config = block_given? ? Config.build(&blk) : Config.with_obj(config)
      @default_request = Request.new(@default_config)
    end

    def env_config
      opts = Config::OPTS.each_with_object({}) do |k, h|
        env_key = "tincheck_#{k}"
        h[k] = ENV[env_key] if ENV.key?(env_key)
      end
      Config.new(opts)
    end

    def request(request_hash)
      default_request.(request_hash)
    end
    alias call request

    Request::SERVICES.keys.each do |k|
      define_method(k) { |**kwargs| default_request.public_send(k, kwargs) }
    end
  end
  configure
end
