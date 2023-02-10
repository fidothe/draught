module Draught
  class DeCasteljau
    def self.split(world, curve_segment, t)
      new(world).split(curve_segment, t)
    end

    attr_reader :world

    def initialize(world)
      @world = world
    end

    def split(curve_segment, t)
      rank_1 = split_points(line_segments(curve_segment), t)
      rank_2 = split_points(new_segments(rank_1), t)
      split_point = split_points(new_segments(rank_2), t).first

      [
        curve_segment_before_split(curve_segment.start_point, rank_1, rank_2, split_point),
        curve_segment_after_split(split_point, rank_1, rank_2, curve_segment.end_point)
      ]
    end

    private

    def curve_segment_before_split(start_point, rank_1, rank_2, end_point)
      world.curve_segment.build(
        start_point: start_point,
        control_point_1: rank_1.first,
        control_point_2: rank_2.first,
        end_point: end_point
      )
    end

    def curve_segment_after_split(start_point, rank_1, rank_2, end_point)
      world.curve_segment.build(
        start_point: start_point,
        control_point_1: rank_2.last,
        control_point_2: rank_1.last,
        end_point: end_point
      )
    end

    def split_points(segments, t)
      segments.map { |segment| segment.compute_point(t) }
    end

    def new_segments(points)
      (0..(points.length - 2)).map { |start|
        world.line_segment.build(Hash[[:start_point, :end_point].zip(points[start, 2])])
      }
    end

    def line_segments(curve_segment)
      points = [curve_segment.start_point, curve_segment.control_point_1, curve_segment.control_point_2, curve_segment.end_point]
      new_segments(points)
    end
  end
end
