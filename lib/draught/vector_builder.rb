require_relative './vector'

module Draught
  class VectorBuilder
    attr_reader :world, :null

    def initialize(world)
      @world = world
      @null = new(0, 0)
    end

    def new(x, y)
      Vector.new(x, y, world)
    end

    def build(x, y)
      Vector.new(x, y, world)
    end

    def from_xy(x, y)
      new(x, y)
    end

    def from_degrees_and_magnitude(degrees, magnitude)
      radians = degrees * (Math::PI / 180)
      from_radians_and_magnitude(radians, magnitude)
    end

    def from_radians_and_magnitude(radians, magnitude)
      x = Math.cos(radians) * magnitude
      y = Math.sin(radians) * magnitude
      new(x, y)
    end

    def translation_to_zero(point)
      translation_between(point, world.point.zero)
    end

    def translation_between(point_1, point_2)
      from_xy(point_2.x - point_1.x, point_2.y - point_1.y)
    end
  end
end
