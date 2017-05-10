module Draught
  module Pathlike
    def points
      raise NotImplementedError, "Pathlike objects must return an array of their points"
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

    def approximates?(other, delta)
      return false if number_of_points != other.number_of_points
      points.zip(other.points).all? { |a, b| a.approximates?(b, delta) }
    end

    def paths
      [self]
    end

    def containers
      []
    end
  end
end
