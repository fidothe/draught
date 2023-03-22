require_relative './cubic_bezier'

module Draught
  class CubicBezierBuilder
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def build(end_point:, control_point_1:, control_point_2:)
      CubicBezier.new(world, end_point: end_point, control_point_1: control_point_1, control_point_2: control_point_2)
    end
  end
end
