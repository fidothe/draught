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

        def build(**kwargs)
          Line.build(world, **kwargs)
        end

        def from_to(p1, p2, metadata: nil)
          build(start_point: p1, end_point: p2, metadata: metadata)
        end

        def from_path(path_or_subpath)
          case path_or_subpath
          when Draught::Subpath
            from_subpath(path_or_subpath)
          else
            if path_or_subpath.number_of_subpaths != 1
              raise ArgumentError, "path must contain exactly 1 subpath, this contained #{path_or_subpath.number_of_subpaths}"
            end
            from_subpath(path_or_subpath.subpaths.first, metadata: path_or_subpath.metadata)
          end
        end

        private

        def build_args(required_args, optional_args)
          required_args.merge(optional_args.select { |k,_| k == :metadata })
        end

        def from_subpath(subpath, metadata: nil)
          if subpath.number_of_points != 2
            raise ArgumentError, "path's 1 subpath must contain exactly 2 points, this contained #{subpath.number_of_points}"
          end
          build(start_point: subpath.first, end_point: subpath.last, metadata: metadata)
        end
      end
    end
  end
end
