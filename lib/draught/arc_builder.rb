require_relative './point'
require_relative './vector'
require_relative './cubic_bezier'
require_relative './curve'
require_relative './path'
require_relative './transformations'

module Draught
  class ArcBuilder
    LARGEST_SEGMENT_RADIANS = Math::PI / 2.0
    CIRCLE_RADIANS = Math::PI * 2

    attr_reader :radius, :starting_angle, :radians

    def self.deg_to_rad(degrees)
      degrees * (Math::PI / 180)
    end

    def self.radians(args = {})
      new_args = args.merge(radians: args[:angle])
      new(new_args)
    end

    def self.degrees(args = {})
      new_args = {radius: args[:radius]}
      new_args[:radians] = deg_to_rad(args.fetch(:angle))
      new_args[:starting_angle] = deg_to_rad(args.fetch(:starting_angle, 0))
      new(new_args)
    end

    def self.build(args = {})
      if args.has_key?(:degrees)
        args = args.merge({radians: radians(args[:degrees])})
      end
      new(args)
    end

    def initialize(args = {})
      @radius = args.fetch(:radius)
      @starting_angle = args.fetch(:starting_angle, 0)
      @radians = args.fetch(:radians)
    end

    def path
      @path ||= Path.new([start_point, curve])
    end

    def start_point
      @start_point ||= untranslated_start_point.transform(transformer)
    end

    def curve
      @curve ||= Curve.new({
        point: segments.last.end_point,
        cubic_beziers: segments.map { |s| s.cubic_bezier }
      }).transform(transformer)
    end

    private

    def untranslated_start_point
      segments.first.first_point
    end

    def segments
      @segments ||= begin
        remaining_angle = positive_radians
        start = starting_angle
        segments = []
        while remaining_angle > LARGEST_SEGMENT_RADIANS
          remaining_angle = remaining_angle - LARGEST_SEGMENT_RADIANS
          segments << SegmentBuilder.new(LARGEST_SEGMENT_RADIANS, start, radius)
          start = radians + starting_angle - remaining_angle
        end
        segments << SegmentBuilder.new(remaining_angle, start, radius)
      end
    end

    def positive_radians
      radians.abs
    end

    def transformer
      @transformer ||= begin
        transformations = [translation_transformer]
        transformations << Transformations.x_axis_reflect if negative?
        Transformations::Composer.compose(*transformations)
      end
    end

    def translation_transformer
      @translation_transformer ||= Vector.translation_between(untranslated_start_point, Point::ZERO).to_transform
    end

    def negative?
      !positive?
    end

    def positive?
      radians >= 0
    end

    # @api: private
    # Based on learnings from http://www.tinaja.com/glib/bezcirc2.pdf,
    # via http://www.whizkidtech.redprince.net/bezier/circle/
    class SegmentBuilder
      attr_reader :sweep, :start, :radius

      def initialize(sweep, start, radius)
        @sweep, @start, @radius = sweep, start, radius
      end

      def first_point
        @first_point ||= Point.new(x0, -y0).transform(transform)
      end

      def end_point
        @end_point ||= Point.new(x0, y0).transform(transform)
      end

      def cubic_bezier
        @cubic_bezier ||= CubicBezier.new({
          end_point: end_point, control_point_1: control_point_1, control_point_2: control_point_2
        })
      end

      private

      def control_point_1
        Point.new(x1, -y1).transform(transform)
      end

      def control_point_2
        Point.new(x1, y1).transform(transform)
      end

      def transform
        @transform ||= Transformations::Composer.compose(
          Transformations.rotate(start + sweep_offset), Transformations.scale(radius)
        )
      end

      def sweep_offset
        @sweep_offset ||= sweep / 2.0
      end

      def x0
        Math.cos(sweep_offset)
      end

      def y0
        Math.sin(sweep_offset)
      end

      def x1
        (4 - x0)/3.0
      end

      def y1
        ((1 - x0) * (3 - x0)) / (3 * y0)
      end
    end
  end
end
