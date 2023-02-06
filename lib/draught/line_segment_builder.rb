require_relative './line_segment'

module Draught
  # Provides methods for building LineSegment objects, two-point straight lines,
  # via length, angle and length, or from an existing two-item path
  class LineSegmentBuilder
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def horizontal(width, args = {})
      build(build_args({end_point: world.point.new(width, 0)}, args))
    end

    def vertical(height, args = {})
      build(build_args({end_point: world.point.new(0, height)}, args))
    end

    def build(args = {})
      LineSegment.build(world, args)
    end

    def from_to(p1, p2, args = {})
      build(build_args({start_point: p1, end_point: p2}, args))
    end

    def from_path(path)
      if path.number_of_points != 2
        raise ArgumentError, "path must contain exactly 2 points, this contained #{path.number_of_points}"
      end
      build(build_args({start_point: path.first, end_point: path.last}, {metadata: path.metadata}))
    end

    private

    def build_args(required_args, optional_args)
      required_args.merge(optional_args.select { |k,_| k == :metadata })
    end
  end
end
