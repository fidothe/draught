require_relative './point'
require_relative './vector'
require_relative './cubic_bezier'
require_relative './path'
require_relative './transformations'
require_relative './pathlike'
require_relative './boxlike'
require 'forwardable'

module Draught
  # Represents a circular arc of a specified radius and size in radians. Can
  # generate a series of cubic beziers to represent up to a full circle.
  class Arc
    # Largest arc segment representable by a single Cubic Bézier is 90º
    # There's enough jitter in floating point maths that we round the result
    # to 12 d.p. which means we avoid requiring two segments to represent an
    # arc of 90.000000000000000001º
    LARGEST_SEGMENT_RADIANS = (Math::PI / 2.0).round(12)

    extend Forwardable
    include Pathlike
    include Boxlike

    attr_reader :world, :radius, :starting_angle, :radians, :start_point
    # @!attribute [r] world
    #   @return [World] the World
    # @!attribute [r] radius
    #   @return [Number] the radius of the Arc's circle
    # @!attribute [r] starting_angle
    #   @return [Number] the angle at which the Arc begins, in radians
    # @!attribute [r] radians
    #   @return [Number] the angular size of the Arc, in radians
    # @!attribute [r] start_point
    #   @return [Point] the Point the arc path starts at

    def_delegators :path, :points, :"[]", :width, :height, :lower_left, :lower_right, :upper_left, :upper_right

    # @param world [World] the world
    # @param args [Hash] the arc arguments.
    # @option args [Number] :radius The radius
    # @option args [Number] :starting_angle (0) the angle at which the arc begins
    # @option args [Number] :radians (0) the size of the arc
    # @option args [Draught::Point] :start_point (0,0) the point the arc should start at
    # @option args [Draught::Style] :style (nil) Styles that should be attached to the Arc
    def initialize(world, args = {})
      @world = world
      @radius = args.fetch(:radius)
      @starting_angle = args.fetch(:starting_angle, 0)
      @radians = args.fetch(:radians)
      @style = args.fetch(:style, nil)
      @start_point = args.fetch(:start_point, world.point.zero)
    end

    # @return [Path]
    def path
      @path ||= world.path.new(points: [start_point] + cubic_beziers, style: style)
    end

    # @return [Array<CubicBezier>]
    def cubic_beziers
      @cubic_beziers ||= segments.map { |s| s.cubic_bezier.transform(transformer) }
    end

    def style
      @style ||= Style.new
    end

    def with_new_style(style)
      self.class.new(world, new_args.merge(style: style))
    end

    def translate(vector)
      path.translate(vector)
    end

    def transform(transformer)
      path.transform(transformer)
    end

    def box_type
      [:path]
    end

    def paths
      []
    end

    def containers
      []
    end

    private

    def new_args
      {radius: radius, radians: radians, starting_angle: starting_angle, start_point: start_point, style: style}
    end

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
          segments << SegmentBuilder.new(world, LARGEST_SEGMENT_RADIANS, start, radius)
          start = positive_radians + starting_angle - remaining_angle
        end
        segments << SegmentBuilder.new(world, remaining_angle, start, radius)
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
      @translation_transformer ||= world.vector.translation_between(untranslated_start_point, start_point).to_transform
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
      attr_reader :world, :sweep, :start, :radius

      def initialize(world, sweep, start, radius)
        @world, @sweep, @start, @radius = world, sweep, start, radius
      end

      def first_point
        @first_point ||= world.point.new(x0, -y0).transform(transform)
      end

      def end_point
        @end_point ||= world.point.new(x0, y0).transform(transform)
      end

      def cubic_bezier
        @cubic_bezier ||= CubicBezier.new(world, {
          end_point: end_point, control_point_1: control_point_1, control_point_2: control_point_2
        })
      end

      private

      def control_point_1
        world.point.new(x1, -y1).transform(transform)
      end

      def control_point_2
        world.point.new(x1, y1).transform(transform)
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
