require_relative './tolerance'
require_relative './point_builder'
require_relative './vector_builder'
require_relative './arc_builder'
require_relative './circle_builder'
require_relative './path/builder'
require_relative './segment/line/builder'
require_relative './segment/curve/builder'

module Draught
  # The World represents the environment in which all objects are created.
  #
  # Comparison and intersections are slightly fuzzy - floating point maths and
  # how far we have to go to say that one thing is, for any reasonable
  # interpretation, in the same place as another. The World defines the
  # tolerance - a Draught::Tolerance - that all objects in the World will use
  # when they are compared or checked for intersections.
  #
  # The assumption is that all objects must use the same Tolerance, so we can
  # simplify object creation by providing builder objects that can ensure the
  # correct Tolerance is used and that stop us having to worry about that.
  class World
    # @!attribute [r] tolerance
    #   @return [Tolerance] the World's tolerance object
    attr_reader :tolerance

    def self.create_builder(method_name, builder_class)
      ivar_name = "#{method_name}_builder"
      builder_method_name = "#{method_name}_builder"
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{builder_method_name}
          @#{ivar_name} ||= #{builder_class.name}.new(self)
        end
      METHOD
      class_eval <<-METHOD, __FILE__, __LINE__ + 2
        def #{method_name}(*args, **kwargs)
          if args.empty? && kwargs.empty?
            #{builder_method_name}
          else
            #{builder_method_name}.build(*args, **kwargs)
          end
        end
      METHOD
    end

    def initialize(tolerance = Tolerance::DEFAULT)
      @tolerance = tolerance
    end

    # Create Points
    #
    # @overload point()
    #   Return the PointBuilder
    #   @return [PointBuilder] the builder for producing Point objects
    # @overload point(x, y)
    #   Create a new Point directly
    #   @param x [Number] The point's X coord.
    #   @param y [Number] The point's Y coord.
    #   @return [Point] the Point
    create_builder :point, PointBuilder

    # Create Vectors
    #
    # @overload vector()
    #   Return the VectorBuilder
    #   @return [VectorBuilder] the builder for producing Point objects
    # @overload vector(x, y)
    #   Create a new Vector directly
    #   @param x [Number] The vector's X magnitude.
    #   @param y [Number] The vector's Y magnitude.
    #   @return [Vector] the Vector
    create_builder :vector, VectorBuilder

    # Create Arc objects
    #
    # @overload arc()
    #   Return the ArcBuilder
    #   @return [ArcBuilder] the builder for producing Arc objects
    # @overload arc(start_point:, radius:, radians:, start_angle: nil, metadata: nil)
    #   Create a new Arc directly
    #   @param radians [Number] The size of the arc.
    #   @param radius [Number] The radius of the circular the arc is from.
    #   @param start_point [Point] (0,0) The start point.
    #   @param start_angle [Number] (0) The angle the arc starts from.
    #   @param metadata [Metadata::Instance] (nil) Metadata for the segment.
    #   @return [Arc] the arc
    create_builder :arc, ArcBuilder

    # Create Arc objects
    #
    # @overload circle()
    #   Return the CircleBuilder
    #   @return [CircleBuilder] the builder for producing Arc objects
    # @overload arc(center:, radius:, metadata: nil)
    #   Create a new Arc directly
    #   @param center [Point] (0,0) The center of the circle.
    #   @param radius [Number] The radius of the circle.
    #   @param metadata [Metadata::Instance] (nil) Metadata for the segment.
    #   @return [Circle] the circle
    create_builder :circle, CircleBuilder

    # @return [PathBuilder] the builder for producing Path objects
    def path
      @path ||= Path::Builder.new(self)
    end

    # Create Segment::Line objects
    #
    # @overload line_segment()
    #   Return the Segment::Line::Builder
    #   @return [Segment::Line::Builder] the builder for producing Segment::Line objects
    # @overload line_segment(start_point:, end_point:, metadata: nil)
    #   Create a new Segment::Line directly
    #   @param start_point [Point] The start point.
    #   @param end_point [Point] The end point.
    #   @param metadata [Metadata::Instance] (nil) Metadata for the segment.
    #   @return [Segment::Line] the line segment
    # @overload line_segment(start_point:, radians:, length:, metadata: nil)
    #   Create a new Segment::Line directly
    #   @param start_point [Point] The start point.
    #   @param radians [Number] The angle of the line in Radians.
    #   @param length [Number] The length of the line.
    #   @param metadata [Metadata::Instance] (nil) Metadata for the segment.
    #   @return [Segment::Line] the line segment
    create_builder :line_segment, Segment::Line::Builder

    # Create Segment::Curve objects
    #
    # @overload curve_segment()
    #   Return the Segment::Curve::Builder
    #   @return [Segment::Curve::Builder] the builder for producing Segment::Curve objects
    # @overload curve_segment(start_point:, end_point:, control_point_1:, control_point_2:, metadata: nil)
    #   Create a new Segment::Curve directly
    #   @param start_point [Point] The start point.
    #   @param end_point [Point] The end point.
    #   @param control_point_1 [Point] The first Cubic Bezier control point.
    #   @param control_point_2 [Point] The second Cubic Bezier control point.
    #   @param metadata [Metadata::Instance] (nil) Metadata for the segment.
    #   @return [Segment::Curve] the line segment
    # @overload curve_segment(start_point:, cubic_bezier:, metadata: nil)
    #   Create a new Segment::Curve directly
    #   @param start_point [Point] The start point.
    #   @param cubic_bezier [CubicBezier] The Cubic Bezier Pointlike.
    #   @param metadata [Metadata::Instance] (nil) Metadata for the segment.
    #   @return [Segment::Curve] the line segment
    create_builder :curve_segment, Segment::Curve::Builder

    def inspect
      "#<#{self.class.name}:%#x tolerance: delta=#{tolerance.delta}, precision=#{tolerance.precision}>" % self.object_id
    end
  end
end
