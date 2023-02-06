require_relative './arc'

module Draught
  # Builds an Arc by specifying size and starting angle in either degrees or
  # radians
  class ArcBuilder
    attr_reader :world

    def deg_to_rad(degrees)
      degrees * (Math::PI / 180)
    end

    def radians(args = {})
      new_args = args.merge(radians: args[:angle])
      new(new_args)
    end

    def degrees(args = {})
      new_args = args.select { |k,_| [:radius, :metadata] }
      new_args[:radians] = deg_to_rad(args.fetch(:angle))
      new_args[:starting_angle] = deg_to_rad(args.fetch(:starting_angle, 0))
      new(new_args)
    end

    def new(args = {})
      Arc.new(world, args)
    end

    def initialize(world)
      @world = world
    end
  end
end
