require_relative './arc'
require_relative './pathlike'
require_relative './boxlike'
require_relative './extent'
require_relative './transformations'
require 'forwardable'

module Draught
  # Represents a circular arc of a specified radius and size in radians. Can
  # generate a series of cubic beziers to represent up to a full circle.
  class Circle
    extend Forwardable
    include Pathlike
    include Boxlike
    include Extent::InstanceMethods

    CIRCLE_RADIANS = Math::PI * 2

    attr_reader :world, :radius
    # @!attribute [r] world
    #   @return [World] the World
    # @!attribute [r] radius
    #   @return [Number] the radius of the circle
    # @!attribute [r] annotation
    #   @return [Annotation] an Annotation for the Path

    def_delegators :arc, :points, :subpaths
    def_delegators :to_path, :"[]"

    # @param world [World] the world
    # @param radius [Number] the radius
    # @param center [Point] (radius,radius) the centre point
    # @param metadata [Draught::Metadata::Instance] (nil) Metadata that should be attached to the Circle
    def initialize(world, radius:, center: nil, metadata: nil)
      @world, @radius, @center, @metadata = world, radius, center, metadata
    end

    # @return [Path]
    def to_path
      @path ||= arc.to_path
    end

    # @return [Point] the centre of the circle
    def center
      @center ||= world.point(radius, radius)
    end

    # @return [true] Circles are closeable.
    def closeable?
      true
    end

    # Circles are inherently closed, return self.
    # @return [Circle] return self
    def closed
      self
    end

    # @return [true] Circles are never open.
    def open?
      false
    end

    # @return [false] Circles are inherently closed.
    def closed?
      true
    end

    def extent
      @extent ||= Draught::Extent.new(world, items: [
        center.translate(world.vector(-radius,-radius)), center.translate(world.vector(radius,radius))
      ])
    end

    # @return [Arc] an Arc representing this circle
    def arc
      @arc ||= world.arc(radius: radius, radians: CIRCLE_RADIANS, start_point: center.translate(arc_translation_vector), metadata: metadata)
    end

    # return a copy of this object with a different Metadata instance attached
    #
    # @param style [Metadata::Instance] the metadata to use
    # @return [Circle] the copy of this Circle with new metadata
    def with_metadata(metadata)
      self.class.new(world, radius: radius, center: center, metadata: metadata)
    end

    def translate(vector)
      self.class.new(world, radius: radius, center: center.translate(vector), metadata: metadata)
    end

    def transform(transformer)
      to_path.transform(transformer)
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

    # @return [Vector] the vector between the circle's centre and the arc's centre [radius,0]
    def arc_translation_vector
      @arc_translation_vector ||= world.vector(radius, 0)
    end
  end
end
