require_relative '../../transformations'

module Draught
  module Segment
    class Line
      class FromAngles
        attr_reader :world, :start_point, :length, :radians, :metadata
        private :start_point, :length, :radians, :metadata

        def self.build(...)
          new(...).line_segment_args
        end

        def initialize(world, start_point: world.point.zero, length:, radians:, metadata: nil)
          @world = world
          @start_point, @length, @radians, @metadata = start_point.position_point, length, radians, metadata
        end

        def line_segment_args
          {length: length, radians: radians, start_point: start_point, end_point: end_point, metadata: metadata}
        end

        private

        def end_point
          end_point_from_zero.translate(world.vector.translation_between(world.point.zero, start_point))
        end

        def end_point_from_zero
          hardwired_end_points.fetch(restricted_radians) {
            single_quadrant_end_point.transform(Transformations.rotate(remaining_angle))
          }
        end

        def restricted_radians
          @restricted_radians ||= restrict_to_360_degrees(radians)
        end

        def restrict_to_360_degrees(radians)
          radians % DEGREES_360
        end

        def hardwired_end_points
          {
            0 => world.point.new(length,0),
            DEGREES_90 => world.point.new(0,length),
            DEGREES_180 => world.point.new(-length,0),
            DEGREES_270 => world.point.new(0,-length),
            DEGREES_360 => world.point.new(length,0)
          }
        end

        def single_quadrant_end_point
          world.point.new(x, y)
        end

        def x
          Math.cos(single_quadrant_angle) * length
        end

        def y
          Math.sin(single_quadrant_angle) * length
        end

        def single_quadrant_angle
          @single_quadrant_angle ||= restricted_radians - remaining_angle
        end

        def remaining_angle
          @remaining_angle ||= begin
            [DEGREES_270, DEGREES_180, DEGREES_90, 0].find { |angle|
              restricted_radians > angle
            } || 0
          end
        end
      end
    end
  end
end
