# frozen-string-literal: true

module TINCheck
  MAJOR = 0
  MINOR = 1
  TINY  = 0
  VERSION = [MAJOR, MINOR, TINY].join('.').freeze

  def self.version
    VERSION
  end
end
