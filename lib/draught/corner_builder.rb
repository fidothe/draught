require_relative './corner_builder/rounded'

module Draught
  class CornerBuilder
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def join_rounded(args)
      radius = args.fetch(:radius)
      paths = args.fetch(:paths)

      paths.inject { |incoming, outgoing|
        Rounded.join(world, radius: radius, incoming: incoming, outgoing: outgoing)
      }
    end
  end
end
