module Draught
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def points
      [self]
    end

    def ==(other)
      other.x == x && other.y == y
    end

    def translate(point)
      Point.new(x + point.x, y + point.y)
    end
  end
end
