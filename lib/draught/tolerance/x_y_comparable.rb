module Draught
  class Tolerance
    # Provides the methods for comparing an object that has X,Y coords like
    # Points and Vectors.
    module XYComparable
      # Report whether this object could be compared with the other. (Point ==
      # Point is ok, Point == Vector is not.)
      # @param other [Object] the object to be compared against
      # @return [Boolean] whether they could be compared
      def compare_compatible?(other)
        raise NotImplementedError, "including classes must be able to report if another object could meaningfully be compared with this one"
      end

      # @return [Tolerance] the tolerance
      def tolerance
        raise NotImplementedError, "including classes must report their tolerance"
      end

      def within_tolerance?(tolerance, other)
        tolerance.within?(x, other.x) && tolerance.within?(y, other.y)
      end

      def ==(other)
        compare_compatible?(other) && within_tolerance?(tolerance, other)
      end
    end
  end
end