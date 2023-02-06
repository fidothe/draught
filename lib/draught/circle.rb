require_relative './arc'
require_relative './pathlike'
require_relative './boxlike'
require_relative './transformations'
require 'forwardable'

module Draught
  # Represents a circular arc of a specified radius and size in radians. Can
  # generate a series of cubic beziers to represent up to a full circle.
  class Circle
    extend Forwardable
    include Pathlike
    include Boxlike

    CIRCLE_RADIANS = Math::PI * 2

    attr_reader :world, :radius
    # @!attribute [r] world
    #   @return [World] the World
    # @!attribute [r] radius
    #   @return [Number] the radius of the circle
    # @!attribute [r] annotation
    #   @return [Annotation] an Annotation for the Path

    def_delegators :path, :points, :"[]"

    # @param world [World] the world
    # @param args [Hash] the circle arguments.
    # @option args [Number] :radius The radius
    # @option args [Point] :center The centre point
    # @option args [Draught::Metadata::Instance] :metadata (nil) Metadata that should be attached to the Circle
    def initialize(world, args = {})
      @world = world
      @radius = args.fetch(:radius)
      @center = args.fetch(:center, nil)
      @metadata = args.fetch(:metadata, nil)
    end

    # @return [Path]
    def path
      @path ||= arc.path
    end

    # @return [Point] the centre of the circle
    def center
      @center ||= world.point.new(radius, radius)
    end

    # @return [Number] the width of the circle
    def width
      @width ||= radius * 2
    end

    # @return [Number] the height of the circle
    def height
      @height ||= radius * 2
    end

    # @return [Point] the top-left of the bounding box surrounding the circle
    def upper_left
      @top_left ||= center.translate(world.vector.new(-radius, radius))
    end

    # @return [Point] the top-left of the bounding box surrounding the circle
    def upper_right
      @top_right ||= center.translate(world.vector.new(radius, radius))
    end

    # @return [Point] the top-left of the bounding box surrounding the circle
    def lower_left
      @bottom_left ||= center.translate(world.vector.new(-radius, -radius))
    end

    # @return [Point] the top-left of the bounding box surrounding the circle
    def lower_right
      @bottom_right ||= center.translate(world.vector.new(radius, -radius))
    end

    # @return [Arc] an Arc representing this circle
    def arc
      @arc ||= world.arc.new(radius: radius, radians: CIRCLE_RADIANS, start_point: center.translate(arc_translation_vector), metadata: metadata)
    end

    # return a copy of this object with a different Metadata instance attached
    #
    # @param style [Metadata::Instance] the metadata to use
    # @return [Circle] the copy of this Circle with new metadata
    def with_metadata(metadata)
      self.class.new(world, new_args.merge(metadata: metadata))
    end

    def translate(vector)
      translate_args = new_args.merge(center: center.translate(vector))
      self.class.new(world, translate_args)
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
      {radius: radius, center: center, metadata: metadata}
    end

    # @return [Vector] the vector between the circle's centre and the arc's centre [radius,0]
    def arc_translation_vector
      @arc_translation_vector ||= world.vector.new(radius, 0)
    end
  end
end
