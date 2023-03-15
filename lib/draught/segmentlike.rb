module Draught
  module Segmentlike
    module ClassMethods
      # @return [false] Segments are not closeable.
      def closeable?
        false
      end

      # @return [true] Segments are openable.
      def openable?
        true
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    # @return [false] Segments are not closeable.
    def closeable?
      false
    end

    # @return [true] Segments are openable.
    def openable?
      true
    end

    # Close an open path, but segments cannot be closed. Always raises an error.
    # @raise [TypeError] Segments cannot be closed.
    def closed
      raise TypeError, "Cannot close a segment"
    end

    # Open an open path, which just returns self.
    # @return [Segmentlike] itself.
    def opened
      self
    end

    # @return [true] Segments are always open.
    def open?
      true
    end

    # @return [false] Segments cannot be closed.
    def closed?
      false
    end

    # Split the segment at the given value of t
    # @return [Array<Draught::SegmentLike>] the two segments resulting from the split
    def split(t)
      raise NotImplementedError, "Implementors of SegmentLike must implement #split"
    end

    # @return [Draught::Point] the point at the given value of t
    def compute_point(t)
      raise NotImplementedError, "Implementors of SegmentLike must implement #compute_point"
    end

    # @return [Float] the value of t closest to the given point
    def project_point(point)
      raise NotImplementedError, "Implementors of SegmentLike must implement #project_point"
    end
  end
end