# frozen-string-literal: true

require 'nokogiri'
require 'tincheck/xml'

module TINCheck
  module XML
    module Nokogiri
      class Parser
        include XML::Parser

        private

        def root(xml)
          ::Nokogiri::XML(xml) { |c| c.options = ::Nokogiri::XML::ParseOptions::NOBLANKS }
        end

        def value_with!(element)
          element.elements.empty? ? text_or_nil(element.text) : hash_with(*element.elements)
        end
      end

      class Serializer
        include XML::Serializer

        def call(hash)
          ::Nokogiri::XML::Document.new.tap { |d| add_xml_elements!(d, hash) }.to_s
        end

        private

        def attributes_or_elements!(parent, key, value)
          return parent[key] = text_with(value) if attributes.include?(key)
          e = ::Nokogiri::XML::Element.new(key, parent)
          parent.add_child(e)
          add_xml_elements!(e, value)
        end

        def insert_text!(element, text)
          element.add_child(text_with(text))
        end
      end
    end
  end
end
