module Draught
  class ValueWithTolerance
    include Comparable

    def initialize(value, tolerance)
      @value, @tolerance = value.to_f, tolerance
    end

    def <=>(other)
      return 0 if self == other
      @value <=> other
    end

    def ==(other)
      @tolerance.within?(@value, other)
    end

    def to_f
      @value
    end
  end
end
