require_relative './circle'

module Draught
  # Builds an Arc by specifying size and starting angle in either degrees or
  # radians
  class CircleBuilder
    attr_reader :world

    # Build a circle of a given radius
    #
    # @param radius [Number] the radius of the Circle
    # @param center [Point] (radius,radius) the center of the Circle
    # @param metadata [Metadata::Instance] metadata for the Circle
    def build(**kwargs)
      Circle.new(world, **kwargs)
    end

    def initialize(world)
      @world = world
    end
  end
end
