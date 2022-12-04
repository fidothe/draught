require_relative './line_segment'

module Draught
  # Provides methods for building LineSegment objects, two-point straight lines,
  # via length, angle and length, or from an existing two-item path
  class LineSegmentBuilder
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def horizontal(width)
      build(end_point: world.point.new(width, 0))
    end

    def vertical(height)
      build(end_point: world.point.new(0, height))
    end

    def build(args = {})
      LineSegment.build(world, args)
    end

    def from_path(path)
      if path.number_of_points != 2
        raise ArgumentError, "path must contain exactly 2 points, this contained #{path.number_of_points}"
      end
      build(start_point: path.first, end_point: path.last)
    end
  end
end
