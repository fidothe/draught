require_relative '../curve'
require_relative '../../cubic_bezier'

module Draught
  module Segment
    class Curve
      # Provides methods for building Segment::Curve objects via start and cubic bezier points, start, end and control points, or from an existing two-item (point + cubic) path
      class Builder
        attr_reader :world

        def initialize(world)
          @world = world
        end

        def build(start_point:, cubic_bezier: nil, control_point_1: nil, control_point_2: nil, end_point: nil, metadata: nil)
          if !control_point_1.nil?
            Curve.new(world, start_point: start_point,
              cubic_bezier: Draught::CubicBezier.new(world,
                control_point_1: control_point_1, control_point_2: control_point_2, end_point: end_point
              ), metadata: metadata
            )
          else
            Curve.new(world, start_point: start_point, cubic_bezier: cubic_bezier, metadata: metadata)
          end
        end

        def from_path(path)
          if path.number_of_subpaths != 1
            raise ArgumentError, "path must contain exactly 1 subpath, this contained #{path.number_of_subpaths}"
          end
          subpath = path.subpaths.first
          if subpath.number_of_points != 2
            raise ArgumentError, "path's 1 subpath must contain exactly 2 points, this contained #{subpath.number_of_points}"
          end
          unless subpath.first.is_a?(Point)
            raise ArgumentError, "the first point on the path must be a Point instance, this was #{path.first.inspect}"
          end
          unless subpath.last.is_a?(CubicBezier)
            raise ArgumentError, "the last point on the path must be a CubicBezier instance, this was #{path.last.inspect}"
          end

          build(start_point: subpath.first, cubic_bezier: subpath.last, metadata: path.metadata)
        end
      end
    end
  end
end
