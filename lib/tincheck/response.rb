# frozen-string-literal: true

require 'tincheck/xml'

module TINCheck
  class Response
    APIError = Class.new(RuntimeError)
    ConfigError = Class.new(RuntimeError)
    HTTPError = Class.new(RuntimeError)

    include Enumerable

    class << self
      def with_http_response(http_response, parser:)
        http_ok?(http_response)
        new(http_response.body, parser: parser)
      end

      private

      def http_error(http_response)
        "server responded with #{http_response.code} instead of 200"
      end

      def http_ok?(http_response)
        raise HTTPError, http_error(http_response) unless http_response.code == '200'
      end
    end

    def initialize(xml, parser:)
      @to_h = merge_results(parser.(xml).values)
    end

    def [](key)
      @to_h[key]
    end

    def calls_remaining
      self['CallsRemaining'] == 'No Limit' ? nil : self['CallsRemaining'].to_i
    end

    def death_record?
      self['DMF_CODE'] == '1'
    end

    def each(*args, &blk)
      @to_h.each(*args, &blk)
    end

    def merge_results(results)
      results.reduce({}) { |h, rs| h.merge(rs) }
    end

    def name_and_tin_match?
      %w[1 6 7 8].include?(self['TINNAME_CODE'])
    end

    def to_h
      @to_h.dup
    end
    alias to_hash to_h

    def watch_lists?
      self['LISTSMATCH_CODE'] == '1'
    end
  end
end
