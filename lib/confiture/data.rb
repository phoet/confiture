module Confiture
  class Data
    attr_accessor :options

    def initialize(defaults)
      @options = defaults.dup if defaults
      @options ||= {}
    end
  end
end
