require_relative './tolerance'
require_relative './point_builder'
require_relative './vector_builder'
require_relative './arc_builder'
require_relative './path_builder'
require_relative './line_segment_builder'
require_relative './curve_segment_builder'

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

    def initialize(tolerance = Tolerance::DEFAULT)
      @tolerance = tolerance
    end

    # @return [PointBuilder] the builder for producing Point objects
    def point
      @point ||= PointBuilder.new(self)
    end

    # @return [VectorBuilder] the builder for producing Vector objects
    def vector
      @vector ||= VectorBuilder.new(self)
    end

    # @return [ArcBuilder] the builder for producing Arc objects
    def arc
      @arc ||= ArcBuilder.new(self)
    end

    # @return [PathBuilder] the builder for producing Path objects
    def path
      @path ||= PathBuilder.new(self)
    end

    # @return [LineSegmentBuilder] the builder for producing LineSegment objects
    def line_segment
      @line_segment ||= LineSegmentBuilder.new(self)
    end

    # @return [CurveSegmentBuilder] the builder for producing CurveSegment objects
    def curve_segment
      @curve_segment ||= CurveSegmentBuilder.new(self)
    end
  end
end
