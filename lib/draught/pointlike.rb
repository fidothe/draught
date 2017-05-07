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
