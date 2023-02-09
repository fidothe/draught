require_relative './circle'

module Draught
  # Builds an Arc by specifying size and starting angle in either degrees or
  # radians
  class CircleBuilder
    attr_reader :world

    def new(args = {})
      Circle.new(world, args)
    end

    def initialize(world)
      @world = world
    end
  end
end
