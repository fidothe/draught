require 'matrix'
require_relative './transformations/affine'

module Draught
  class Vector
    def self.from_xy(x, y)
      new(x, y)
    end

    def self.from_degrees_and_magnitude(degrees, magnitude)
      radians = degrees * (Math::PI / 180)
      from_radians_and_magnitude(radians, magnitude)
    end

    def self.from_radians_and_magnitude(radians, magnitude)
      x = Math.cos(radians) * magnitude
      y = Math.sin(radians) * magnitude
      new(x, y)
    end

    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
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
