require 'forwardable'
require_relative './extent'
require_relative './boxlike'
require_relative './pathlike'
require_relative './subpath'

module Draught
  # A Path is a representation of a line or shape – a series of points connected
  # by lines or curves.
  #
  # Paths are made up of one or more distinct connected point series, or
  # subpaths. A simple straight line is a single subpath with two points. A
  # square is a series of 4 points where the last point connects back to the
  # first ('closed'). A Square with a smaller hole in the middle is a single
  # path containing two subpaths - one for the bounds of the square, and one for
  # the hole.
  #
  # Subpaths don't have to overlap, it's fine for them to define separate
  # ('disjoint') shapes. A path is considered as a single unit when applying
  # transformations and translation: the subpaths are fixed in their
  # relationship with each other.
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

    attr_reader :world, :subpaths
    # @!attribute [r] world
    #   @return [World] the World
    # @!attribute [r] subpaths
    #   @return [Array<Subpath>] the Points that make up the Path
    # @!attribute [r] metadata
    #   @return [Metadata] Metadata for the Path

    # @param world [World] the world
    # @param subpaths [Array<Draught::Subpath>] the Path's Subpaths
    # @param metadata [Draught::Metadata] a Metadata object that should be attached to the Path
    def initialize(world, subpaths: [], metadata: nil)
      @world, @subpaths, @metadata = world, subpaths, metadata
    end

    def <<(point)
      append(point)
    end

    def append(*paths_or_subpaths)
      new_instance_with_added_subpaths do |new_subpaths|
        paths_or_subpaths.inject(new_subpaths) { |new_subpaths, path_or_subpath| new_subpaths.append(*path_or_subpath.subpaths) }
      end
    end

    def prepend(*paths_or_subpaths)
      new_instance_with_added_subpaths do |new_subpaths|
        to_prepend = paths_or_subpaths.inject([]) { |to_prepend, path_or_subpath| to_prepend.append(*path_or_subpath.subpaths) }
        new_subpaths.prepend(*to_prepend)
      end
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          new_instance_with_subpaths(subpaths[index_start_or_range])
        when Numeric
          subpaths[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        new_instance_with_subpaths(subpaths[index_start_or_range, length])
      end
    end

    # @return [Extent] the extent of this Path
    def extent
      @extent ||= Extent.from_pathlike(world, items: subpaths)
    end

    def translate(vector)
      new_instance_with_subpaths(subpaths.map { |s| s.translate(vector) })
    end

    def transform(transformer)
      new_instance_with_subpaths(subpaths.map { |s| s.transform(transformer) })
    end

    def pretty_print(q)
      q.group(1, '(P', ')') do
        q.seplist(subpaths, ->() { }) do |subpath|
          q.breakable
          q.pp subpath
        end
      end
    end

    # return a copy of this object with a new Metadata attached
    #
    # @param style [Metadata::Instance] the Metadata to use
    # @return [Path] the copy of this Path with the new metadata
    def with_metadata(metadata)
      self.class.new(world, subpaths: subpaths, metadata: metadata)
    end

    private

    def new_instance_with_added_subpaths
      new_subpaths = subpaths.dup
      yield(new_subpaths)
      new_instance_with_subpaths(new_subpaths)
    end

    def new_instance_with_subpaths(subpaths)
      self.class.new(world, subpaths: subpaths, metadata: metadata)
    end
  end
end
