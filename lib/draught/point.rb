module Draught
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def points
      [self]
    end
  end
end
