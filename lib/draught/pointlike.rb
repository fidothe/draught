module Draught
  module Pointlike
    def x
      raise NotImplementedError, "including classes must return an x value"
    end

    def y
      raise NotImplementedError, "including classes must return an y value"
    end

    def point_type
      raise NotImplementedError, "including classes must return a Symbol with their point type"
    end

    # @return [Point] the position of the point, for path-closedness-duplicate-point
    def position_point
      raise NotImplementedError, "including classes must return a Draught::Point that returns the position to use when checking for first and last points of a path being at the same position"
    end

    # @return [Point] the position of the point, for path-closedness-duplicate-point
    def position_equal?(other)
      other.is_a?(Pointlike) && position_point == other.position_point
    end

    def ==(other)
      raise NotImplementedError, "including classes must implement equality checking. It's assumed other point_types are always unequal"
    end

    def approximates?(other, delta)
      raise NotImplementedError, "including classes must implement approximate equality checking. It's assumed other point_types are always unequal"
    end

    def translate(vector)
      raise NotImplementedError, "including classes must return a new instance translated by the vector arg"
    end

    def transform(transformer)
      raise NotImplementedError, "including classes must return a new instance transformed by the Affine transform or lambda Point-based transform supplied"
    end

    def points
      [self]
    end
  end
end
