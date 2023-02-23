require 'forwardable'
require_relative './extent'
require_relative './boxlike'
require_relative './pathlike'

module Draught
  # A Path is a representation of a line or shape – a series of points connected
  # by lines or curves.
  #
  # Paths are made up of one or more distinct connected point series. Unlike SVG
  # Paths, Draught Paths can only contain a single set of connected points.
  # Compound paths (paths containing subpaths) are handled separately.
  #
  # A simple straight line is a single subpath with two points. A square is a
  # series of 4 points where the last point connects back to the first
  # ('closed').
  #
  # Paths are immutable, so operations that seem like they modify a path are
  # actually creating a copy of the original path with the modifications.
  #
  # {Path::Builder} provides a DSL for creating paths piecemeal. Once the
  # builder block is finished, the complete Path is returned.
  class Path
    include Boxlike
    include Pathlike
    include Extent::InstanceMethods

    attr_reader :world, :points
    # @!attribute [r] world
    #   @return [World] the World
    # @!attribute [r] points
    #   @return [Array<Point>] the Points that make up the Path
    # @!attribute [r] metadata
    #   @return [Metadata] Metadata for the Path

    # @param world [World] the world
    # @param points [Array<Point>] the Path's Points
    # @param closed [Boolean] whether this Path should be treated as a closed path
    # @param metadata [Draught::Metadata] a Metadata object that should be attached to the Path
    def initialize(world, points: [], closed: false, metadata: nil)
      @world, @points, @closed, @metadata = world, points, closed, metadata
    end

    def <<(*points)
      append(*points)
    end

    # Create a new Path by appending the given points to the end of the current Path.
    #
    # @param paths_or_points [Array<Pathlike, Pointlike>] the points to append, or paths whose points should be appended
    # @return [Path] a new Path with the given points appended
    def append(*paths_or_points)
      new_instance_with_added_points do |existing_points|
        existing_points.append(*flatten_points_sources(paths_or_points))
      end
    end

    # Create a new Path by prepending the given points to the end of the current Path.
    #
    # @param paths_or_points [Array<Pathlike, Pointlike>] the points to append, or paths whose points should be appended
    # @return [Path] a new Path with the given points prepended
    def prepend(*paths_or_points)
      new_instance_with_added_points do |existing_points|
        existing_points.prepend(*flatten_points_sources(paths_or_points))
      end
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          new_instance_with_points(points[index_start_or_range])
        when Numeric
          points[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        new_instance_with_points(points[index_start_or_range, length])
      end
    end

    # @return [Boolean] true if the Path is closed (the last point connects back to the first point)
    def closed?
      @closed
    end

    # @return [Boolean] true if the Path is open (the last point does not connect back to the first point)
    def open?
      !closed?
    end

    # Can this Path be closed? (yes, all paths can technically be closed)
    #
    # @return [Boolean] true
    def closeable?
      true
    end

    # Create a closed copy of this Path, if it's open. Returns itself if it's already closed.
    def closed
      return self if closed?
      self.class.new(world, points: points, metadata: metadata, closed: true)
    end

    # @return [Extent] the extent of this Path
    def extent
      @extent ||= Extent.new(world, items: points)
    end

    def translate(vector)
      new_instance_with_points(points.map { |p| p.translate(vector) })
    end

    def transform(transformer)
      new_instance_with_points(points.map { |p| p.transform(transformer) })
    end

    def pretty_print(q)
      q.group(1, '(P', ')') do
        q.seplist(points, ->() { }) do |point|
          q.breakable
          q.pp point
        end
      end
    end

    # @return [Draught::Path] itself
    def to_path
      self
    end


    # return a copy of this object with a new Metadata attached
    #
    # @param style [Metadata::Instance] the Metadata to use
    # @return [Path] the copy of this Path with the new metadata
    def with_metadata(metadata)
      self.class.new(world, points: points, metadata: metadata)
    end

    private

    # Take an array of paths, points, or arrays of them, and return an array of
    # Points. Used to flatten arguments to #append and #prepend.
    def flatten_points_sources(paths_or_points)
      new_points = paths_or_points.lazy.flat_map { |path_or_point|
        case path_or_point
        when Pathlike
          path_or_point.points
        else
          path_or_point
        end
      }
    end

    def new_instance_with_added_points
      new_points = points.dup
      yield(new_points)
      new_instance_with_points(new_points)
    end

    def new_instance_with_points(points)
      self.class.new(world, points: points, metadata: metadata)
    end
  end
end
