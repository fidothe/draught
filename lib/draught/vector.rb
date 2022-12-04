require 'matrix'
require_relative './transformations/affine'
require_relative './point'

module Draught
  class Vector
    attr_reader :x, :y, :world, :tolerance

    def initialize(x, y, world)
      @x, @y, @world, @tolerance = x, y, world, world.tolerance
    end

    def ==(other)
      other.respond_to?(:to_transform) && other.x == x && other.y == y
    end

    def to_transform
      @transform ||= Transformations::Affine.new(
        Matrix[[1, 0, x], [0, 1, y], [0, 0, 1]]
      )
    end
  end
end
