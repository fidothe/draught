require_relative './arc'

module Draught
  # Builds an Arc by specifying size and starting angle in either degrees or
  # radians
  class ArcBuilder
    attr_reader :world

    def deg_to_rad(degrees)
      degrees * (Math::PI / 180)
    end

    # Build an Arc of a circle, specifying the angle in Radians.
    #
    # @param angle [Number] the Arc angle in radians
    # @param starting_angle [Number] (0) the angle in radians the Arc starts at
    # @param radius [Number] the radius of the Arc
    # @param start_point [Point] (0,0) the Point the Arc starts from
    # @param metadata [Metadata::Instance] metadata for the Arc
    def radians(angle:, starting_angle: 0, radius:, start_point: nil, metadata: nil)
      build(radians: angle, starting_angle: starting_angle, radius: radius,
        start_point: start_point, metadata: metadata)
    end

    # Build an Arc of a circle, specifying the angle in Degrees.
    #
    # @param angle [Number] the Arc angle in degrees
    # @param starting_angle [Number] (0) the angle in degrees the Arc starts at
    # @param radius [Number] the radius of the Arc
    # @param start_point [Point] (0,0) the Point the Arc starts from
    # @param metadata [Metadata::Instance] metadata for the Arc
    def degrees(angle:, starting_angle: 0, radius:, start_point: nil, metadata: nil)
      build(radians: deg_to_rad(angle), starting_angle: deg_to_rad(starting_angle), radius: radius,
        start_point: start_point, metadata: metadata)
    end

    def build(**kwargs)
      Arc.new(world, **kwargs)
    end

    def initialize(world)
      @world = world
    end
  end
end
