require_relative './corner_builder/rounded'

module Draught
  # Connects supplied paths together with corners
  class CornerBuilder
    attr_reader :world

    def initialize(world)
      @world = world
    end

    # Join a series of paths using rounded corners by translating the paths
    # start-to-end and replacing the sharp corner with a circular arc of the
    # specified radius.
    #
    # @param paths [Array<Draught::Path>] the paths to join with rounded corners
    # @param radius [Integer, Float] the radius of the corner rounding
    # @param metadata [Draught::Metadata::Instance] (nil) metadata to attach
    # @return [Draught::Path] the resulting joined-with-corners path
    def join_rounded(*paths, radius:, metadata: nil)
      paths.inject { |incoming, outgoing|
        Rounded.join(world, radius: radius, incoming: incoming, outgoing: outgoing, metadata: metadata)
      }
    end
  end
end
