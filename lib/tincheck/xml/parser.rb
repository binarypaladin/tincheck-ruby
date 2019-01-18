# frozen-string-literal: true

module TINCheck
  module XML
    module Parser
      def call(xml)
        at_depth(3, hash_with(root(xml)))
      end

      private

      def at_depth(num, hash)
        return unless hash.is_a?(Hash)
        nh = hash.values.first
        num.zero? ? nh : at_depth(num - 1, nh)
      end

      def hash_with(*nodes)
        nodes.each_with_object({}) do |n, h|
          inject_or_merge!(h, n.name, value_with!(n))
        end
      end

      def inject_or_merge!(hash, key, value)
        if hash.key?(key)
          cv = hash[key]
          value = cv.is_a?(Array) ? cv.push(value) : [cv, value]
        end
        hash[key] = value
      end

      def text_or_nil(text)
        return if !text || text.empty? || text[0] == "\n"
        text
      end
    end
  end
end
