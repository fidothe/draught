require_relative './point'

module Draught
  class PointBuilder
    attr_reader :world, :tolerance, :zero

    def initialize(world)
      @world = world
      @tolerance = world.tolerance
      @zero = Point.new(0, 0, world)
    end

    def new(x, y)
      Point.new(x, y, world)
    end

    def build(x, y)
      Point.new(x, y, world)
    end

    def from_matrix(matrix)
      x, y = matrix.to_a.flatten
      build(x, y)
    end
  end
end
