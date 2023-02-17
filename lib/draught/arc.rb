require_relative './point'
require_relative './vector'
require_relative './cubic_bezier'
require_relative './path'
require_relative './transformations'
require_relative './pathlike'
require_relative './boxlike'
require_relative './extent'
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
    include Extent::InstanceMethods

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
    # @!attribute [r] metadata
    #   @return [Metadata::Instance] Metadata for the arc

    def_delegators :path, :"[]"

    # @param world [World] the world
    # @param radius [Number] the Arc's radius
    # @param starting_angle [Number] (0) the angle at which the arc begins
    # @param radians [Number] the size of the arc
    # @param start_point [Draught::Point] (0,0) the point the arc should start at
    # @param metadata [Draught::Metadata::Instance] (nil) Metadata for the Arc
    def initialize(world, radius:, starting_angle: 0, radians:, start_point: nil, metadata: nil)
      @world, @radius, @starting_angle, @radians, @metadata = world, radius, starting_angle, radians, metadata
      @start_point = start_point.nil? ? world.point.zero : start_point
    end

    # @return [Path]
    def path
      @path ||= world.path.new(subpaths: subpaths, metadata: metadata)
    end

    # @return [Array<Subpath>] the array-of-1-subpaths for the arc
    def subpaths
      @subpaths ||= [subpath]
    end

    # @return [Array<CubicBezier>]
    def cubic_beziers
      @cubic_beziers ||= segments.map(&:cubic_bezier)
    end

    # @return [Array<Pointlike>] the starting Point and following CubicBeziers
    def points
      @points ||= [start_point] + cubic_beziers
    end

    # return a copy of this object with a different Metadata attached
    #
    # @param style [Metadata::Instance] the metadata to use
    # @return [Arc] the copy of this Arc with new metadata
    def with_metadata(metadata)
      self.class.new(world, radius: radius, radians: radians, starting_angle: starting_angle, start_point: start_point, metadata: metadata)
    end

    # @return [Draught::Extent] the Extent for this Arc
    def extent
      @extent ||= Draught::Extent.from_pathlike(world, items: segments)
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

    def subpath
      @subpath ||= Draught::Subpath.new(world, points: points)
    end

    def untranslated_start_point
      untranslated_segments.first.start_point
    end

    def segments
      @segments ||= untranslated_segments.map { |segment| segment.transform(transformer) }
    end

    def untranslated_segments
      @untranslated_segments ||= build_segments
    end

    def build_segments
      remaining_angle = positive_radians
      start = starting_angle
      segments = []
      while remaining_angle > LARGEST_SEGMENT_RADIANS
        remaining_angle = remaining_angle - LARGEST_SEGMENT_RADIANS
        segments << SegmentBuilder.build(world, LARGEST_SEGMENT_RADIANS, start, radius)
        start = positive_radians + starting_angle - remaining_angle
      end
      segments << SegmentBuilder.build(world, remaining_angle, start, radius)
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
      def self.build(world, sweep, start, radius)
        new(world, sweep, start, radius).segment
      end

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

      def segment
        Segment::Curve.new(world, start_point: first_point, cubic_bezier: cubic_bezier)
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
