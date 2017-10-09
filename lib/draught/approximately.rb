module Draught
  class Approximately
    PRECISION = 6

    def self.equal?(v1, v2)
      new(v1).is_approximately?(v2)
    end

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def delta
      @delta ||= 1 * (10 ** -PRECISION)
    end

    def is_approximately?(other)
      (value - other).abs.round(PRECISION) <= delta
    end

    def <=>(other)
      return 0 if is_approximately?(other)
      value <=> other
    end
  end
end
