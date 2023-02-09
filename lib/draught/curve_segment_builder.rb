require_relative './curve_segment'
require_relative './cubic_bezier'

module Draught
  # Provides methods for building LineSegment objects, two-point straight lines,
  # via length, angle and length, or from an existing two-item path
  class CurveSegmentBuilder
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def build(args = {})
      if args.has_key?(:control_point_1)
        args = args.select { |k, _| k == :metadata }.merge({
          start_point: args.fetch(:start_point),
          cubic_bezier: CubicBezier.new(world, args)
        })
      end
      CurveSegment.new(world, args)
    end

    def from_path(path)
      if path.number_of_points != 2
        raise ArgumentError, "path must contain exactly 2 points, this contained #{path.number_of_points}"
      end
      unless path.first.is_a?(Point)
        raise ArgumentError, "the first point on the path must be a Point instance, this was #{path.first.inspect}"
      end
      unless path.last.is_a?(CubicBezier)
        raise ArgumentError, "the last point on the path must be a CubicBezier instance, this was #{path.last.inspect}"
      end

      build(start_point: path.first, cubic_bezier: path.last, metadata: path.metadata)
    end
  end
end
