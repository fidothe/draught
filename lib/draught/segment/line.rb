require_relative './line/from_point'
require_relative './line/from_angles'
require_relative '../extent'
require_relative '../pathlike'
require_relative '../boxlike'
require_relative '../segmentlike'


module Draught
  module Segment
    # Represents a two-point line. Has length, and angle.
    class Line
      DEGREES_90 = Math::PI / 2
      DEGREES_180 = Math::PI
      DEGREES_270 = Math::PI * 1.5
      DEGREES_360 = Math::PI * 2

      include Boxlike
      include Pathlike
      include Segmentlike
      include Extent

      # @return [false] Arcs are not closeable.
      def self.closeable?
        false
      end

      # @return [false] Arcs are openable.
      def self.openable?
        true
      end

      def self.build(world, **args)
        builder_class = args.has_key?(:end_point) ? FromPoint : FromAngles
        line_segment_args = builder_class.build(world, args)
        new(world, line_segment_args)
      end

      attr_reader :world, :start_point, :end_point, :length, :radians
      # @!attribute [r] world
      #   @return [World] the World
      # @!attribute [r] start_point
      #   @return [Point] the Point the LineSegment starts at
      # @!attribute [r] end_point
      #   @return [Point] the Point the LineSegment ends at
      # @!attribute [r] length
      #   @return [Number] the length of the LineSegment
      # @!attribute [r] radians
      #   @return [Number] the angle of the LineSegment in radians.

      # @param world [World] the world
      # @param args [Hash] the Path arguments.
      # @option args [Draught::Point] (PointBuilder.zero) :start_point the start Point of the line
      # @option args [Draught::Point] :end_point the end Point of the line
      # @option args [Number] :length the length of the line
      # @option args [Number] :radians the angle of the line, in radians
      # @option args [Draught::Metadata] :metadata (nil) a Metadata object that should be attached to the LineSegment
      def initialize(world, args)
        @world = world
        @start_point = args.fetch(:start_point, world.point.zero)
        @end_point = args.fetch(:end_point)
        @length = args.fetch(:length)
        @radians = args.fetch(:radians)
        @metadata = args.fetch(:metadata, nil)
      end

      def points
        @points ||= [start_point, end_point]
      end

      def center
        @center ||= compute_point(0.5)
      end

      def compute_point(t)
        return start_point if t == 0
        return end_point if t == 1

        t = t.to_f
        mt = 1 - t

        x = mt * start_point.x + t * end_point.x
        y = mt * start_point.y + t * end_point.y
        world.point(x, y)
      end

      # def project_point(point)
      #   x_t = (point.x - start_point.x) / (end_point.x - start_point.x).to_f
      #   y_t = (point.y - start_point.y) / (end_point.y - start_point.y).to_f
      #   raise ArgumentError, "Point #{point} is not on the line #{self}" unless x_t == y_t
      #   x_t
      # end

      # cribbing from https://math.stackexchange.com/questions/2193720/find-a-point-on-a-line-segment-which-is-the-closest-to-other-point-not-on-the-li
      def project_point(point)
        v_x = (end_point.x - start_point.x).to_f
        v_y = (end_point.y - start_point.y).to_f
        u_x = (start_point.x - point.x).to_f
        u_y = (start_point.y - point.y).to_f
        vu = (v_x * u_x) + (v_y * u_y)
        vv = (v_x ** 2) + (v_y ** 2)
        t = -vu / vv

        return t if t >= 0 && t <= 1
        t < 0 ? 0 : 1
      end

      def extend(args = {})
        default_args = {at: :end}
        args = default_args.merge(args)
        new_length = args[:to] || length + args[:by]
        new_line_segment = self.class.build(world,
          start_point: start_point, length: new_length, radians: radians,
          metadata: metadata)
        args[:at] == :start ? shift_line_segment(new_line_segment) : new_line_segment
      end

      def [](index_start_or_range, length = nil)
        if length.nil?
          case index_start_or_range
          when Range
            world.path.new(points: points[index_start_or_range], metadata: metadata)
          when Numeric
            points[index_start_or_range]
          else
            raise TypeError, "requires a Range or Numeric in single-arg form"
          end
        else
          world.path.new(points: points[index_start_or_range, length], metadata: metadata)
        end
      end

      # @return [Draught::Path] a new Path with the same points as this Segment::Line
      def to_path
        @path ||= world.path.new(points: points, metadata: metadata)
      end

      def translate(vector)
        transformed_instance(->(arg, point) { [arg, point.translate(vector)] })
      end

      def transform(transformation)
        transformed_instance(->(arg, point) { [arg, point.transform(transformation)] })
      end

      # @return [Draught::Extent] the Extent for this Segment
      def extent
        @extent ||= Draught::Extent::Instance.new(world, items: points)
      end

      def line?
        true
      end

      def line
        self
      end

      def curve?
        false
      end

      def split(t)
        split_point = compute_point(t)
        [
          self.class.build(world, start_point: start_point, end_point: split_point),
          self.class.build(world, start_point: split_point, end_point: end_point)
        ]
      end

      def pretty_print(q)
        q.group(1, '(Pl', ')') do
          q.seplist(points, ->() { }) do |point|
            q.breakable
            q.pp point
          end
        end
      end

      def with_metadata(metadata)
        self.class.new(world, {
          start_point: start_point, end_point: end_point, length: length, radians: radians,
          metadata: metadata
        })
      end

      private

      def shift_line_segment(new_line_segment)
        translation = world.vector.translation_between(new_line_segment.end_point, end_point)
        self.class.new(world, {
          start_point: start_point.translate(translation),
          end_point: new_line_segment.end_point.translate(translation),
          length: new_line_segment.length,
          radians: radians,
          metadata: metadata,
        })
      end

      def transformed_instance(mapper)
        args = transform_args_hash.map(&mapper).to_h
        self.class.build(world, metadata: metadata, **args)
      end

      def transform_args_hash
        {start_point: start_point, end_point: end_point}
      end

      def compute_coord(coord_set, t)
        (1 - t) * start_point.send(coord_set) + t * end_point.send(coord_set)
      end
    end
  end
end