module Draught
  class ValueWithTolerance
    def initialize(value, tolerance)
      @value, @tolerance = value, tolerance
    end

    def <=>(other)
      return 0 if self == other
      @value <=> other
    end

    def ==(other)
      @tolerance.within?(@value, other)
    end
  end
end
