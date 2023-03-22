require_relative 'boxlike'
require_relative 'extent'
require_relative 'point'

module Draught
  class BoundingBox
    include Boxlike
    include Extent

    attr_reader :world, :paths

    def initialize(world, paths)
      @world = world
      @paths = paths
    end

    def extent
      @extent ||= Extent::Instance.from_pathlike(world, items: paths)
    end

    def translate(point)
      self.class.new(world, paths.map { |path| path.translate(point) })
    end

    def transform(transformer)
      self.class.new(world, paths.map { |path| path.transform(transformer) })
    end

    def zero_origin
      move_to(world.point.zero)
    end

    def ==(other)
      paths == other.paths
    end

    def containers
      []
    end

    def box_type
      [:container]
    end
  end
end
