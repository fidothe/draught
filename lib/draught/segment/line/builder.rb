require_relative '../line'

module Draught
  module Segment
    class Line
      # Provides methods for building LineSegment objects, two-point straight lines,
      # via length, angle and length, or from an existing two-item path
      class Builder
        attr_reader :world

        def initialize(world)
          @world = world
        end

        def horizontal(width, metadata: nil)
          build(end_point: world.point.new(width, 0), metadata: metadata)
        end

        def vertical(height, metadata: nil)
          build(end_point: world.point.new(0, height), metadata: metadata)
        end

        def build(...)
          Line.build(world, ...)
        end

        def from_to(p1, p2, metadata: nil)
          build(start_point: p1, end_point: p2, metadata: metadata)
        end

        def from_path(path, metadata: nil)
          if path.number_of_points != 2
            raise ArgumentError, "path must contain exactly 2 points, this contained #{path.number_of_points}"
          end
          build(start_point: path.first, end_point: path.last, metadata: metadata || path.metadata)
        end
      end
    end
  end
end
