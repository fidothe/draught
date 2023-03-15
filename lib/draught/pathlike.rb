require_relative 'metadata'

module Draught
  module Pathlike
    module ClassMethods
      # Can all Pathlikes of this class be closed (where the last point connects
      # back to the first point)? Segments, for example, are two-point open
      # paths, and are not closeable...
      #
      # @return [Boolean] true if pathlikes of this class are closeable, false if they are not
      def closeable?
        raise NotImplementedError, "Pathlike classes must implement .closeable?, reporting whether they can be closed (first point connected to last point)"
      end

      # Can this Pathlike be opened (where the last point no longer connects back
      # to the first point)? Circles, for example, are not circles if they are not
      # closed, so they are not openable...
      #
      # @return [Boolean] true if pathlikes of this class are openable, false if they are not
      def openable?
        raise NotImplementedError, "Pathlike classes must implement .openable?, reporting whether they can be opened (first point not connected to last point)"
      end
    end

    include Metadata::Methods

    def self.included(base)
      base.extend(ClassMethods)
    end

    def points
      raise NotImplementedError, "Pathlike objects must implement #points to return any Points they contain"
    end

    # @return [Draught::Path] a path containing the points of this pathlike
    def to_path
      raise NotImplementedError, "Pathlike objects must implement #to_path to return a Draught::Path instance containing their points"
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

    def each(&block)
      points.each(&block)
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

    # Can this Pathlike be closed (where the last point connects back to the
    # first point)? Segments, for example, are two-point open paths, and are not
    # closeable...
    #
    # @return [Boolean] true if the pathlike is closeable, false if it is not
    def closeable?
      raise NotImplementedError, "Pathlike objects must implement #closeable?, reporting whether they can be closed"
    end

    # Can this Pathlike be opened (where the last point no longer connects back
    # to the first point)? Circles, for example, are not circles if they are not
    # closed, so they are not openable...
    #
    # @return [Boolean] true if the pathlike is openable, false if it is not
    def openable?
      raise NotImplementedError, "Pathlike objects must implement #openable?, reporting whether they can be opened (first point not connected to last point)"
    end

    # Is this pathlike open?
    #
    # @return [Boolean] true if the pathlike is open, false if it is not
    def open?
      raise NotImplementedError, "Pathlike objects must implement #open?, reporting whether they are open"
    end

    # Is this pathlike closed?
    #
    # @return [Boolean] true if the pathlike is closed, false if it is not
    def closed?
      raise NotImplementedError, "Pathlike objects must implement #closed?, reporting whether they are closed"
    end

    # Return a copy of this pathlike which has been closed
    #
    # @return [Draught::Pathlike] a closed copy of this pathlike
    # @raise [TypeError] if the pathlike is not closeable
    def closed
      raise NotImplementedError, "Pathlike objects must implement #closed, which returns a closed copy of themself."
    end

    # Return a copy of this pathlike which has been opened
    #
    # @return [Draught::Pathlike] an opened copy of this pathlike
    # @raise [TypeError] if the pathlike is not openable
    def opened
      raise NotImplementedError, "Pathlike objects must implement #opened, which returns an opened copy of themself."
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
