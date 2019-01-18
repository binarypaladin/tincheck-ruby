# frozen-string-literal: true

require 'tincheck/xml/parser'
require 'tincheck/xml/serializer'

module TINCheck
  module XML
    class << self
      def hash_or_array(obj)
        case obj
        when Hash
          yield(obj)
        when Array
          obj.map { |o| yield(o) }
        else
          obj
        end
      end

      def parser_with(name)
        const_get(name)::Parser.new
      end

      def serializer_with(name, attributes: Serializer::ATTRIBUTES)
        const_get(name)::Serializer.new(attributes: attributes)
      end
    end
  end
end
