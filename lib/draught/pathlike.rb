require_relative 'metadata'

module Draught
  module Pathlike
    include Metadata::Methods

    def points
      raise NotImplementedError, "Pathlike objects must implement #points to return any Points they contain"
    end

    def translate(vector)
      raise NotImplementedError, "Pathlike objects must implement translation by Vector"
    end

    def transform(transformation)
      raise NotImplementedError, "Pathlike objects must implement transformation by Affine transform or point-taking lambda"
    end

    def [](index_start_or_range, length = nil)
      raise NotImplementedError, "Pathlike objects must implement [] access on their points, returning a new instance"
    end

    def number_of_points
      points.length
    end

    def first
      points.first
    end

    def last
      points.last
    end

    def empty?
      points.empty?
    end

    def ==(other)
      return false if number_of_points != other.number_of_points
      points.zip(other.points).all? { |a, b| a == b }
    end

    # Standard Pathlikes represent simple paths, so they have no subpaths. For
    # rendering (for example), we need to consider subpaths, so by default all
    # Pathlikes simply return an array of themself
    #
    # @return [Array<Pathlike>] an array containing this pathlike
    def subpaths
      [self]
    end

    def paths
      []
    end

    def containers
      []
    end

    def box_type
      [:path]
    end
  end
end
